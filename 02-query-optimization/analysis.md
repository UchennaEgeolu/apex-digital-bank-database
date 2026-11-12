# Portfolio 2 — Query Processing and Optimisation

**Project:** Apex Digital Bank  
**Module:** MIT 8103 — Advanced Database Systems  
**Database:** `apex_digital_bank` (MySQL 8 / InnoDB)  
**Repository path:** `02-query-optimization/analysis.md`

## 1. Objective

Evaluate the execution plans of three realistic banking queries against a larger synthetic dataset; implement targeted composite indexes; and compare execution-plan choices and observed timings before and after indexing.

## 2. Dataset and methodology

The performance seed was run against the existing Apex Digital Bank schema, preserving the pre-existing account balances and records. The verified dataset contained **5,100 customers, 5,135 bank accounts, and 100,005 transactions**. The seed data is synthetic.

The workflow was: (1) collect baseline `EXPLAIN ANALYZE` output; (2) inspect existing indexes with `SHOW INDEX`; (3) create two targeted indexes; (4) refresh optimizer statistics with `ANALYZE TABLE transactions`; (5) rerun the same queries using `EXPLAIN ANALYZE` and `EXPLAIN FORMAT=TRADITIONAL`; (6) compare plans and measurements.

The screenshots are primary evidence. Any timings below are **observed single-run Workbench execution durations**, not controlled benchmark averages; they should not be represented as statistically reliable speedups. Workbench duration and `EXPLAIN ANALYZE` operator timings are different measurements.

## 3. Workload

### Q1 — Recent transaction history for one account

```sql
SELECT t.transaction_id, t.transaction_reference, t.amount,
       t.direction, t.created_at
FROM transactions AS t
WHERE t.account_id = (
    SELECT account_id FROM bank_accounts
    WHERE account_number = '9000000001'
)
ORDER BY t.created_at DESC
LIMIT 50;
```

The existing `bank_accounts.account_number` unique index supports locating the account. The new `(account_id, created_at DESC)` index supports locating its transactions in recent-first order.

### Q2 — High-value transactions

```sql
SELECT transaction_id, transaction_reference, amount,
       direction, created_at
FROM transactions
WHERE amount >= 500000
ORDER BY created_at DESC
LIMIT 100;
```

The new `(amount, created_at DESC)` index supports the amount range predicate. Because the first index key is a **range** and the requested global ordering is by `created_at`, the optimizer can still need a separate sort.

### Q3 — Top customers by transaction value

```sql
SELECT c.customer_id, c.first_name, c.last_name,
       COUNT(t.transaction_id) AS transaction_count,
       SUM(t.amount) AS total_transaction_value
FROM customers AS c
JOIN bank_accounts AS ba ON ba.customer_id = c.customer_id
JOIN transactions AS t ON t.account_id = ba.account_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_transaction_value DESC
LIMIT 20;
```

This aggregation touches many rows and must compute group totals before ranking customers. The two new transaction indexes were designed primarily for Q1 and Q2, not to eliminate the aggregation work in Q3.

## 4. Index changes

```sql
CREATE INDEX idx_p2_transactions_account_created
    ON transactions (account_id, created_at DESC);

CREATE INDEX idx_p2_transactions_amount_created
    ON transactions (amount, created_at DESC);

ANALYZE TABLE transactions;
```

Both `CREATE INDEX` statements completed successfully, and `SHOW INDEX` verified their existence. These statements are **historical records of work already executed**; do not rerun them without checking for existing indexes.

## 5. Results and interpretation

| Query | Baseline observation | Optimised observation | Interpretation |
|---|---|---|---|
| Q1: Account history | Baseline plan captured | Traditional EXPLAIN shows `transactions` access type `ref`, using `idx_p2_transactions_account_created`; account number resolved using `uq_bank_accounts_account_number`; estimated 3 matching transaction rows | Target index is selected. Small result set limits the significance of a single timing measurement. |
| Q2: High-value transactions | Baseline plan captured | Traditional EXPLAIN shows `range` access using `idx_p2_transactions_amount_created`, with `Using index condition; Using filesort` | Index assists range filtering; sorting remains. This is a partial optimisation, not a sort-free plan. |
| Q3: Customer ranking | Baseline plan captured; earlier Workbench duration approximately 0.230 s | Optimised plan captured; later Workbench duration approximately 0.214 s | No meaningful speedup can be established from two single runs. Full aggregation remains the dominant workload. |

**Important evidence limitation:** The captured `EXPLAIN ANALYZE` result cells are horizontally truncated in several screenshots. Although the plans and selected indexes can be verified from the traditional EXPLAIN screenshots, the screenshots alone do not support an exact before/after operator-time comparison for every query. Therefore this report deliberately avoids unsupported percentage-speedup claims.

### Q1: Why the composite index helps

The predicate restricts by `account_id`, which is the leading key in `idx_p2_transactions_account_created`. The second key (`created_at DESC`) matches the desired recent-first ordering. Traditional EXPLAIN confirms the index was chosen. The unique account-number index also makes the scalar account lookup efficient.

### Q2: Why `Using filesort` remains

The amount predicate is a range (`amount >= 500000`). Entries in `(amount, created_at DESC)` are grouped first by amount; they are **not globally sorted by `created_at`** across all qualifying amounts. MySQL therefore uses the index for filtering and performs a separate filesort for the requested order. An alternative `(created_at DESC, amount)` index might favour recent-first scanning but could examine many nonqualifying rows. Which strategy is better depends on data distribution and selectivity; it requires measurement, not assumption.

### Q3: Why indexing alone does not solve aggregation

The query joins customers, accounts and transactions, groups by customer, sums transaction values, and sorts on a computed aggregate. Even if join keys are indexed, computing totals for many customers requires reading and aggregating the qualifying transaction data. For production-scale reporting, possible future improvements include materialised reporting summaries, scheduled aggregation or analytical replicas; these were **not implemented or benchmarked** in this exercise.

## 6. Evidence files

Save screenshots under `02-query-optimization/execution-plans/`:

**Baseline**
- `baseline/00-dataset-record-counts.png`
- `baseline/01-account-transaction-history-before.png`
- `baseline/02-high-value-transactions-before.png`
- `baseline/03-customer-transaction-report-before.png`

**Optimised**
- `optimized/01-account-transaction-history-after.png`
- `optimized/02-high-value-transactions-after.png`
- `optimized/03-customer-transaction-report-after.png`
- `optimized/04-account-transaction-history-index-verification.png` (traditional EXPLAIN)
- `optimized/05-high-value-transactions-index-verification.png` (traditional EXPLAIN)

Retain the SQL performance seed and index script under the existing `02-query-optimization/` folders. Only include evidence actually captured; do not manufacture missing measurements.

## 7. Conclusions

The practical exercise demonstrated how workload-specific composite indexes affect MySQL query execution. Q1 successfully selected an index aligned with both account filtering and recency ordering. Q2 successfully selected a range index but still needed filesort, showing that an index does not automatically satisfy every query operation. Q3 remained aggregation-heavy, illustrating the limits of ordinary transactional indexes for analytical reporting.

The key architectural lesson is to validate indexing decisions using real query plans and representative data, while distinguishing **index selection** from **measured performance improvement**. The evidence supports the former for Q1 and Q2; rigorous benchmark claims would require repeated timings under comparable conditions.

## 8. AI assistance declaration

AI assistance was used to help structure the experimental methodology, explain MySQL execution plans, and draft this analysis. The database exercises, screenshots, and reported observations were supplied from practical execution in MySQL Workbench. All claims should be checked against the committed SQL scripts and evidence before academic submission.
