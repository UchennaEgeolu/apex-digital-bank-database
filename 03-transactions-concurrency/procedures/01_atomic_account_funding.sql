-- Apex Digital Bank | Portfolio 3 | Atomic account funding | MySQL 8+
-- Prerequisites: baseline schema and reference/customer/account seeders executed.
-- Educational simulation only: this represents externally confirmed settlement;
-- it does NOT connect to a payment gateway or independently verify incoming funds.
-- Run this script once to install/replace the stored procedure. It does NOT fund any account.
USE apex_digital_bank;

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_fund_account $$
CREATE PROCEDURE sp_fund_account(
    IN p_account_number VARCHAR(20),
    IN p_amount DECIMAL(19,4),
    IN p_idempotency_key VARCHAR(100)
)
BEGIN
    DECLARE v_account_id BIGINT UNSIGNED;
    DECLARE v_scheme_code VARCHAR(20);
    DECLARE v_account_status VARCHAR(30);
    DECLARE v_credit_status VARCHAR(30);
    DECLARE v_currency CHAR(3);
    DECLARE v_available DECIMAL(19,4);
    DECLARE v_ledger DECIMAL(19,4);
    DECLARE v_settlement_gl BIGINT UNSIGNED;
    DECLARE v_deposit_gl BIGINT UNSIGNED;
    DECLARE v_channel_id BIGINT UNSIGNED;
    DECLARE v_success_id BIGINT UNSIGNED;
    DECLARE v_operation_id BIGINT UNSIGNED;
    DECLARE v_transaction_id BIGINT UNSIGNED;
    DECLARE v_journal_id BIGINT UNSIGNED;
    DECLARE v_reference VARCHAR(64);
    DECLARE v_count BIGINT DEFAULT 0;
    DECLARE v_now DATETIME(6);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Funding amount must be positive';
    END IF;
    IF p_idempotency_key IS NULL OR CHAR_LENGTH(TRIM(p_idempotency_key)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Idempotency key is required';
    END IF;
    IF p_account_number IS NULL OR CHAR_LENGTH(TRIM(p_account_number)) = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account number is required';
    END IF;

    SET v_now = NOW(6);
    SET v_reference = CONCAT('FUND-', LEFT(SHA2(p_idempotency_key,256),32));
    START TRANSACTION;

    -- The unique index on financial_operations.idempotency_key is the final
    -- concurrency safeguard if two sessions attempt the same request at once.
    SELECT COUNT(*) INTO v_count
    FROM financial_operations WHERE idempotency_key = p_idempotency_key;
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate funding request: idempotency key already used';
    END IF;

    SELECT COUNT(*) INTO v_count FROM bank_accounts WHERE account_number = p_account_number;
    IF v_count <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Bank account not found';
    END IF;

    -- Lock the target account until the journal and both balances are committed.
    SELECT ba.account_id, s.scheme_code, ba.account_status, ba.credit_status,
           ba.currency, ba.available_balance, ba.ledger_balance
    INTO v_account_id, v_scheme_code, v_account_status, v_credit_status,
         v_currency, v_available, v_ledger
    FROM bank_accounts ba
    JOIN account_schemes s ON s.scheme_id = ba.scheme_id
    WHERE ba.account_number = p_account_number
    FOR UPDATE;

    IF v_account_status <> 'ACTIVE' OR v_credit_status <> 'ALLOWED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account is not active or cannot receive credits';
    END IF;
    IF v_currency <> 'NGN' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'This procedure supports NGN funding only';
    END IF;
    IF v_available IS NULL OR v_ledger IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account balances must be initialized';
    END IF;

    SELECT COUNT(*) INTO v_count
    FROM account_restrictions
    WHERE account_id = v_account_id AND is_active = 1
      AND restriction_type IN ('CREDIT','ALL','BOTH')
      AND (effective_from IS NULL OR effective_from <= v_now)
      AND (effective_to IS NULL OR effective_to >= v_now);
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Account has an active credit restriction';
    END IF;

    -- GL codes come from 01_seed_reference_data.sql.
    SELECT COUNT(*) INTO v_count FROM gl_accounts WHERE gl_code = '100100' AND account_class = 'ASSET';
    IF v_count <> 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Settlement asset GL 100100 is missing';
    END IF;
    SELECT gl_account_id INTO v_settlement_gl FROM gl_accounts WHERE gl_code = '100100';

    IF v_scheme_code = 'SAV_NGN' THEN
        SELECT gl_account_id INTO v_deposit_gl FROM gl_accounts
        WHERE gl_code = '200100' AND account_class = 'LIABILITY';
    ELSEIF v_scheme_code = 'CUR_NGN' THEN
        SELECT gl_account_id INTO v_deposit_gl FROM gl_accounts
        WHERE gl_code = '200200' AND account_class = 'LIABILITY';
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unsupported NGN account scheme';
    END IF;
    IF v_deposit_gl IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Deposit liability GL is missing';
    END IF;

    SELECT channel_id INTO v_channel_id FROM transaction_channels WHERE channel_code = 'BRANCH';
    SELECT status_id INTO v_success_id FROM transaction_statuses WHERE status_code = 'SUCCESSFUL';
    IF v_channel_id IS NULL OR v_success_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Reference channel or status is missing';
    END IF;

    INSERT INTO financial_operations
        (operation_reference, operation_type, channel_id, destination_account_id,
         total_amount, currency, idempotency_key, initiated_at)
    VALUES (v_reference, 'ACCOUNT_FUNDING', v_channel_id, v_account_id,
            p_amount, v_currency, p_idempotency_key, v_now);
    SET v_operation_id = LAST_INSERT_ID();

    INSERT INTO transactions
        (transaction_reference, operation_id, account_id, status_id, direction,
         transaction_type, amount, currency, narration, transaction_date, created_at)
    VALUES (CONCAT('TXN-', LEFT(SHA2(p_idempotency_key,256),32)),
            v_operation_id, v_account_id, v_success_id, 'INFLOW',
            'ACCOUNT_FUNDING', p_amount, v_currency,
            'Synthetic settlement-funded deposit', v_now, v_now);
    SET v_transaction_id = LAST_INSERT_ID();

    INSERT INTO transaction_status_history
        (transaction_id, status_id, reason_code, changed_at)
    VALUES (v_transaction_id, v_success_id, 'SETTLEMENT_CONFIRMED', v_now);

    INSERT INTO journal_headers (operation_id, journal_reference, posted_at)
    VALUES (v_operation_id, CONCAT('JRN-', LEFT(SHA2(p_idempotency_key,256),32)), v_now);
    SET v_journal_id = LAST_INSERT_ID();

    -- Balanced double-entry: debit settlement asset, credit customer deposit liability.
    INSERT INTO journal_lines (journal_id, gl_account_id, account_id, entry_type, amount, currency)
    VALUES
        (v_journal_id, v_settlement_gl, NULL, 'DEBIT', p_amount, v_currency),
        (v_journal_id, v_deposit_gl, v_account_id, 'CREDIT', p_amount, v_currency);

    -- Only update cached balances after the matching journal is recorded.
    UPDATE bank_accounts
    SET available_balance = available_balance + p_amount,
        ledger_balance = ledger_balance + p_amount,
        updated_at = v_now
    WHERE account_id = v_account_id;

    INSERT INTO account_balance_snapshots
        (account_id, ledger_balance, available_balance, snapshot_at)
    VALUES (v_account_id, v_ledger + p_amount, v_available + p_amount, v_now);

    COMMIT;
    SELECT v_reference AS operation_reference, v_transaction_id AS transaction_id,
           v_journal_id AS journal_id, p_account_number AS account_number,
           p_amount AS funded_amount, v_currency AS currency;
END $$
DELIMITER ;

-- MANUAL TEST (run separately after choosing a real seeded ACTIVE NGN account):
-- SELECT account_number, account_status, credit_status, currency
-- FROM bank_accounts WHERE currency = 'NGN' AND account_status = 'ACTIVE' LIMIT 5;
-- CALL sp_fund_account('REPLACE_WITH_SEEDED_ACCOUNT_NUMBER', 100000.0000, 'ADB-FUND-TEST-0001');
-- Check operation, journal balance, transaction and account balance:
-- SELECT j.journal_id, SUM(CASE WHEN l.entry_type='DEBIT' THEN l.amount ELSE 0 END) debit_total,
--        SUM(CASE WHEN l.entry_type='CREDIT' THEN l.amount ELSE 0 END) credit_total
-- FROM journal_headers j JOIN journal_lines l ON l.journal_id=j.journal_id
-- GROUP BY j.journal_id ORDER BY j.journal_id DESC LIMIT 5;
-- Repeating the SAME key must fail without creating another posting:
-- CALL sp_fund_account('REPLACE_WITH_SEEDED_ACCOUNT_NUMBER', 100000.0000, 'ADB-FUND-TEST-0001');
