# Portfolio 3 — Transactions and Concurrency Control

**Project:** Apex Digital Bank  
**Module:** MIT 8103 — Advanced Database Systems  
**Database platform:** MySQL 8 / InnoDB  
**Portfolio location:** `03-transactions-concurrency/analysis.md`

## 1. Aim and scope

This portfolio evaluates transactional integrity in a simulated digital banking database. The implementation uses stored procedures for account funding and internal transfers, transaction boundaries, ledger journal entries, idempotency keys, and InnoDB row-level locks. The experiments examine successful posting, rejection of invalid operations, rollback behaviour, and contention between database sessions.

The evidence described below comes from practical MySQL Workbench executions and screenshots. The tests use synthetic customer accounts; no real customer information or funds are involved.

## 2. Relevant database components

| Component | Purpose |
|---|---|
| `bank_accounts` | Stores account details, available balances, and ledger balances. |
| `financial_operations` | Records financial operations and unique idempotency keys. |
| `transactions` | Stores account-facing transaction records and their statuses. |
| `transaction_statuses` | Provides transaction status definitions. |
| `journal_headers` | Groups accounting journal entries associated with operations. |
| `journal_lines` | Stores debit and credit postings against general ledger accounts. |
| `gl_accounts` | Defines the general ledger accounts used for postings. |
| `sp_fund_account` | Stored procedure used in the account-funding experiment. |
| `sp_transfer_funds` | Stored procedure used in internal-transfer and concurrency experiments. |

The database was designed using InnoDB to support transactional commits, rollbacks, and row-level locking. The full stored-procedure source is maintained separately under `03-transactions-concurrency/procedures/`.

## 3. Transaction design and ACID properties

**Atomicity.** A financial transfer should not leave a partial result: the debit, credit, and related financial records must succeed together or be rolled back. The insufficient-funds and lock-timeout tests provide evidence that rejected operations did not produce committed financial-operation records.

**Consistency.** Account balances and ledger entries should remain consistent with defined business and accounting rules. The successful transfer test showed corresponding source and destination balance changes and two journal lines of equal amount. This is evidence for the tested case, not a proof that every possible posting scenario is balanced.

**Isolation.** Concurrent sessions must not modify the same account in conflicting ways. `SELECT ... FOR UPDATE` was used to hold an exclusive row lock while another session attempted a transfer. The competing operation encountered a lock wait timeout.

**Durability.** Successfully committed transfers remained visible in subsequent queries. The screenshots support persistence within the observed database session; a restart/recovery durability test was not performed.

## 4. Test environment and synthetic accounts

- Database schema: `apex_digital_bank`
- Database engine: MySQL 8, InnoDB
- Client: MySQL Workbench, using separate SQL sessions for locking tests
- Source account: `9000000001` — Ada Okafor
- Destination account: `8000000008` — Emeka Adeyemi
- Currency: NGN

These account identifiers and customer names belong to the synthetic assessment dataset.

## 5. Experiments and observed results

### 5.1 Atomic account funding

The procedure `sp_fund_account` was created and invoked to fund source account `9000000001` with **₦100,000**, using idempotency key `ADB-FUND-TEST-0001`.

**Observed:** The account balance became ₦100,000. A corresponding successful inflow transaction and accounting journal evidence were inspected in MySQL Workbench.

**Interpretation:** The tested funding operation updated the customer account and created associated financial records. The result is consistent with an atomic funding workflow.

### 5.2 Successful internal transfer and journal integrity

The procedure `sp_transfer_funds` was created and invoked with:

```sql
CALL sp_transfer_funds(
    '9000000001',
    '8000000008',
    25000.0000,
    'ADB-TRF-TEST-0001'
);
```

**Observed:** The source account decreased from ₦100,000 to **₦75,000**, while the destination account increased to **₦25,000**. The related journal query returned two lines: one **DEBIT ₦25,000** and one **CREDIT ₦25,000**, both in NGN.

**Interpretation:** The account-level transfer conserved the total value between the two accounts. The associated debit and credit journal amounts were equal for this transaction.

### 5.3 Duplicate request / idempotency protection

The same transfer was submitted again with idempotency key `ADB-TRF-TEST-0001`.

**Observed:** MySQL returned a custom **Error 1644: Duplicate transfer idempotency key**. A follow-up query against `financial_operations` returned **one** operation for that key.

**Interpretation:** Repeating the same request did not create a second committed financial operation. This supports protection against duplicate posting for the tested key.

### 5.4 Insufficient-funds rollback

A transfer of **₦200,000** was attempted from an account with a balance of ₦75,000:

```sql
CALL sp_transfer_funds(
    '9000000001',
    '8000000008',
    200000.0000,
    'ADB-TRF-INSUFFICIENT-001'
);
```

**Observed:** MySQL returned **Error 1644: Insufficient available balance**. The source and destination balances remained **₦75,000** and **₦25,000**, respectively. No committed `financial_operations` row was found for `ADB-TRF-INSUFFICIENT-001`.

**Interpretation:** The rejected transfer did not debit the source, credit the destination, or leave a committed financial-operation record.

### 5.5 Competing transfer requests and balance protection

Two transfer requests of **₦50,000** were submitted from the same source account with distinct idempotency keys:

- `ADB-CONCURRENT-A-001`
- `ADB-CONCURRENT-B-001`

**Observed:** Request A succeeded. Request B returned **Error 1644: Insufficient available balance**. The final balances were **₦25,000** for the source account and **₦75,000** for the destination account. Only the first request appeared in the financial-operation query.

**Interpretation:** The procedure prevented an overdraft and duplicate value movement in these two requests. **Limitation:** The captured execution timestamps show that the requests were submitted at different times; this experiment alone does not prove simultaneous contention. That behaviour was tested separately in Section 5.6.

### 5.6 Controlled lock contention between two sessions

Two independent MySQL Workbench sessions were used to create a reproducible locking conflict.

**Session A — acquire and retain an exclusive row lock:**

```sql
USE apex_digital_bank;
START TRANSACTION;

SELECT account_number, available_balance
FROM bank_accounts
WHERE account_number = '9000000001'
FOR UPDATE;

-- Leave this transaction open during Session B's attempt.
```

**Session B — attempt a transfer against the locked account:**

```sql
USE apex_digital_bank;
SET SESSION innodb_lock_wait_timeout = 10;

CALL sp_transfer_funds(
    '9000000001',
    '8000000008',
    10000.0000,
    'ADB-CONCURRENT-LOCK-001'
);
```

**Observed:** Session B returned **MySQL Error 1205: Lock wait timeout exceeded; try restarting transaction** after approximately **10.056 seconds**. Session A subsequently executed `ROLLBACK`, releasing its lock. A follow-up query returned no committed financial operation with idempotency key `ADB-CONCURRENT-LOCK-001`.

**Interpretation:** The transfer could not proceed while another session held an incompatible row lock on the source account. This provides direct evidence of InnoDB row-level locking and lock-wait behaviour under contention. A separate screenshot of the final balances can strengthen the evidence that no account balance changed.

## 6. Summary of test outcomes

| Test | Expected behaviour | Observed outcome | Assessment |
|---|---|---|---|
| Account funding | Credit account and create corresponding financial records | ₦100,000 credited; transaction and journal inspected | Passed for tested case |
| Internal transfer | Debit source, credit destination, and balance journal | ₦25,000 moved; equal debit and credit journal lines | Passed |
| Duplicate idempotency key | Reject repeated posting | Error 1644; one operation recorded | Passed |
| Insufficient funds | Reject transfer without partial posting | Error 1644; balances unchanged; no operation recorded | Passed |
| Competing transfer requests | Prevent overdraft and second posting | First succeeded; second rejected | Passed for sequential competing requests |
| Row-lock contention | Block competing operation while lock held | Error 1205 after ~10.056 seconds | Passed |
| Lock-timeout integrity | No committed operation from failed request | No operation found for failed idempotency key | Passed |

## 7. Screenshot evidence

Screenshots are stored in `03-transactions-concurrency/screenshots/`. Relevant filenames include:

| File | Evidence |
|---|---|
| `11_concurrent_transfer_session_a.png` | Successful first competing transfer |
| `12_concurrent_transfer_session_b.png` | Rejected second competing transfer |
| `13_concurrent_transfer_balance_integrity.png` | Balances after the competing requests |
| `14_concurrent_transfer_operation_integrity.png` | Only the successful competing operation recorded |
| `15_lock_wait_timeout_session_b.png` | Session B's Error 1205 and elapsed time |
| `16_exclusive_row_lock_session_a.png` | Session A's `SELECT ... FOR UPDATE` lock |
| `17_session_a_rollback.png` | Rollback of Session A's locking transaction |
| `19_lock_timeout_integrity_verification.png` | No committed operation after timeout |

Earlier funding, transfer, journal, idempotency, and insufficient-funds screenshots should be retained under their existing filenames. Screenshot number 18 was not provided and is not cited as evidence.

## 8. Discussion and limitations

The experiments show that MySQL transactions and InnoDB locks provide important safeguards for account-based financial operations. In particular, the stored procedure rejected duplicate requests and insufficient-funds requests without creating additional committed operations, while an explicitly held row lock caused a competing transfer to wait and time out.

The following limitations should be acknowledged:

1. The experiments were conducted on a local synthetic dataset, not a production banking system.
2. The two ₦50,000 requests were not shown to execute simultaneously; the separate lock-contention experiment demonstrates overlapping transactions.
3. A lock wait timeout is not the same as a deadlock. A separate deadlock/retry experiment would be required to evaluate deadlock recovery.
4. The screenshots do not establish throughput, scalability, crash recovery, or correctness under every possible concurrent schedule.
5. The complete stored-procedure source should be reviewed to verify that every error path explicitly rolls back and that account locks are acquired in a deterministic order when appropriate.

## 9. Conclusion

Portfolio 3 implemented and tested transactional account funding and internal transfers in Apex Digital Bank. The observed results demonstrate balanced postings for a successful transfer, protection against duplicate and insufficient-funds requests, and InnoDB row-level locking under controlled contention. These results provide practical evidence of atomicity, consistency, and isolation for the tested scenarios, while committed-record persistence provides limited evidence of durability. The exercises also identify opportunities for further testing, including deadlock recovery and concurrent load benchmarking.

## 10. Reproducibility and academic integrity

The repository should include the SQL procedures, test statements, screenshots, and a clear description of the test order. Synthetic data was used throughout. Any use of AI assistance in planning, drafting, SQL review, or documentation should be declared according to the university's assessment policy. All test outcomes reported here are based on the Workbench results shared during the project rather than fabricated benchmark data.
