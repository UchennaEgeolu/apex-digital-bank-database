-- Apex Digital Bank | Portfolio 3 | Atomic internal NGN transfer | MySQL 8+
-- Run to install procedure; it does NOT execute a transfer.
-- Requires schema, reference/account seeders and a funded source account.
USE apex_digital_bank;

DELIMITER $$
DROP PROCEDURE IF EXISTS sp_transfer_funds $$
CREATE PROCEDURE sp_transfer_funds(
    IN p_source_account_number VARCHAR(20),
    IN p_destination_account_number VARCHAR(20),
    IN p_amount DECIMAL(19,4),
    IN p_idempotency_key VARCHAR(100)
)
BEGIN
    DECLARE v_source_id BIGINT UNSIGNED;
    DECLARE v_dest_id BIGINT UNSIGNED;
    DECLARE v_first_id BIGINT UNSIGNED;
    DECLARE v_second_id BIGINT UNSIGNED;
    DECLARE v_locked_id BIGINT UNSIGNED;
    DECLARE v_source_scheme VARCHAR(20);
    DECLARE v_dest_scheme VARCHAR(20);
    DECLARE v_source_status VARCHAR(30);
    DECLARE v_dest_status VARCHAR(30);
    DECLARE v_source_debit VARCHAR(30);
    DECLARE v_dest_credit VARCHAR(30);
    DECLARE v_source_currency CHAR(3);
    DECLARE v_dest_currency CHAR(3);
    DECLARE v_source_available DECIMAL(19,4);
    DECLARE v_source_ledger DECIMAL(19,4);
    DECLARE v_dest_available DECIMAL(19,4);
    DECLARE v_dest_ledger DECIMAL(19,4);
    DECLARE v_source_gl BIGINT UNSIGNED;
    DECLARE v_dest_gl BIGINT UNSIGNED;
    DECLARE v_channel BIGINT UNSIGNED;
    DECLARE v_success BIGINT UNSIGNED;
    DECLARE v_operation BIGINT UNSIGNED;
    DECLARE v_journal BIGINT UNSIGNED;
    DECLARE v_outflow BIGINT UNSIGNED;
    DECLARE v_inflow BIGINT UNSIGNED;
    DECLARE v_count BIGINT DEFAULT 0;
    DECLARE v_now DATETIME(6);
    DECLARE v_hash CHAR(64);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transfer amount must be positive';
    END IF;
    IF p_idempotency_key IS NULL OR TRIM(p_idempotency_key) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Idempotency key is required';
    END IF;
    IF p_source_account_number IS NULL OR p_destination_account_number IS NULL
       OR TRIM(p_source_account_number) = '' OR TRIM(p_destination_account_number) = ''
       OR p_source_account_number = p_destination_account_number THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Two different account numbers are required';
    END IF;

    SET v_now = NOW(6);
    SET v_hash = SHA2(CONCAT('TRANSFER:',p_idempotency_key),256);
    START TRANSACTION;

    -- Unique idempotency index provides the final concurrent-request safeguard.
    SELECT COUNT(*) INTO v_count FROM financial_operations
      WHERE idempotency_key = p_idempotency_key;
    IF v_count <> 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Duplicate transfer idempotency key';
    END IF;

    SELECT account_id INTO v_source_id FROM bank_accounts
      WHERE account_number = p_source_account_number;
    SELECT account_id INTO v_dest_id FROM bank_accounts
      WHERE account_number = p_destination_account_number;
    IF v_source_id IS NULL OR v_dest_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source or destination account not found';
    END IF;

    -- Lock both accounts in consistent primary-key order to reduce deadlocks.
    SET v_first_id = LEAST(v_source_id,v_dest_id);
    SET v_second_id = GREATEST(v_source_id,v_dest_id);
    SELECT account_id INTO v_locked_id FROM bank_accounts
      WHERE account_id = v_first_id FOR UPDATE;
    SELECT account_id INTO v_locked_id FROM bank_accounts
      WHERE account_id = v_second_id FOR UPDATE;

    SELECT s.scheme_code, a.account_status, a.debit_status, a.currency,
           a.available_balance, a.ledger_balance
      INTO v_source_scheme, v_source_status, v_source_debit, v_source_currency,
           v_source_available, v_source_ledger
      FROM bank_accounts a JOIN account_schemes s ON s.scheme_id = a.scheme_id
      WHERE a.account_id = v_source_id;
    SELECT s.scheme_code, a.account_status, a.credit_status, a.currency,
           a.available_balance, a.ledger_balance
      INTO v_dest_scheme, v_dest_status, v_dest_credit, v_dest_currency,
           v_dest_available, v_dest_ledger
      FROM bank_accounts a JOIN account_schemes s ON s.scheme_id = a.scheme_id
      WHERE a.account_id = v_dest_id;

    IF v_source_status <> 'ACTIVE' OR v_source_debit <> 'ALLOWED'
       OR v_dest_status <> 'ACTIVE' OR v_dest_credit <> 'ALLOWED' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source debit or destination credit not permitted';
    END IF;
    IF v_source_currency <> 'NGN' OR v_dest_currency <> 'NGN' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Internal transfers currently support NGN only';
    END IF;
    IF v_source_available IS NULL OR v_source_ledger IS NULL
       OR v_dest_available IS NULL OR v_dest_ledger IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Uninitialized account balance';
    END IF;
    IF v_source_available < p_amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Insufficient available balance';
    END IF;

    SELECT COUNT(*) INTO v_count FROM account_restrictions
      WHERE account_id = v_source_id AND is_active = 1
        AND restriction_type IN ('DEBIT','ALL','BOTH')
        AND (effective_from IS NULL OR effective_from <= v_now)
        AND (effective_to IS NULL OR effective_to >= v_now);
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Source account has an active debit restriction';
    END IF;
    SELECT COUNT(*) INTO v_count FROM account_restrictions
      WHERE account_id = v_dest_id AND is_active = 1
        AND restriction_type IN ('CREDIT','ALL','BOTH')
        AND (effective_from IS NULL OR effective_from <= v_now)
        AND (effective_to IS NULL OR effective_to >= v_now);
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Destination account has an active credit restriction';
    END IF;

    -- Customer deposits are liabilities: debit source liability, credit destination liability.
    IF v_source_scheme = 'SAV_NGN' THEN
        SELECT gl_account_id INTO v_source_gl FROM gl_accounts
          WHERE gl_code = '200100' AND account_class = 'LIABILITY';
    ELSEIF v_source_scheme = 'CUR_NGN' THEN
        SELECT gl_account_id INTO v_source_gl FROM gl_accounts
          WHERE gl_code = '200200' AND account_class = 'LIABILITY';
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unsupported source account scheme';
    END IF;
    IF v_dest_scheme = 'SAV_NGN' THEN
        SELECT gl_account_id INTO v_dest_gl FROM gl_accounts
          WHERE gl_code = '200100' AND account_class = 'LIABILITY';
    ELSEIF v_dest_scheme = 'CUR_NGN' THEN
        SELECT gl_account_id INTO v_dest_gl FROM gl_accounts
          WHERE gl_code = '200200' AND account_class = 'LIABILITY';
    ELSE
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Unsupported destination account scheme';
    END IF;
    IF v_source_gl IS NULL OR v_dest_gl IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Required deposit liability GL missing';
    END IF;

    SELECT channel_id INTO v_channel FROM transaction_channels WHERE channel_code = 'MOBILE';
    SELECT status_id INTO v_success FROM transaction_statuses WHERE status_code = 'SUCCESSFUL';
    IF v_channel IS NULL OR v_success IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Required transaction channel or status missing';
    END IF;

    INSERT INTO financial_operations
      (operation_reference, operation_type, channel_id, source_account_id,
       destination_account_id, total_amount, currency, idempotency_key, initiated_at)
    VALUES (CONCAT('TRF-',LEFT(v_hash,32)), 'INTERNAL_TRANSFER', v_channel,
            v_source_id, v_dest_id, p_amount, 'NGN', p_idempotency_key, v_now);
    SET v_operation = LAST_INSERT_ID();

    INSERT INTO transactions
      (transaction_reference, operation_id, account_id, status_id, direction,
       transaction_type, amount, currency, narration, transaction_date, created_at)
    VALUES (CONCAT('TXN-OUT-',LEFT(v_hash,32)), v_operation, v_source_id, v_success,
            'OUTFLOW', 'INTERNAL_TRANSFER', p_amount, 'NGN',
            CONCAT('Transfer to ',p_destination_account_number), v_now, v_now);
    SET v_outflow = LAST_INSERT_ID();
    INSERT INTO transactions
      (transaction_reference, operation_id, account_id, status_id, direction,
       transaction_type, amount, currency, narration, transaction_date, created_at)
    VALUES (CONCAT('TXN-IN-',LEFT(v_hash,32)), v_operation, v_dest_id, v_success,
            'INFLOW', 'INTERNAL_TRANSFER', p_amount, 'NGN',
            CONCAT('Transfer from ',p_source_account_number), v_now, v_now);
    SET v_inflow = LAST_INSERT_ID();

    INSERT INTO transaction_status_history (transaction_id,status_id,reason_code,changed_at)
    VALUES (v_outflow,v_success,'INTERNAL_TRANSFER_POSTED',v_now),
           (v_inflow,v_success,'INTERNAL_TRANSFER_POSTED',v_now);

    INSERT INTO journal_headers (operation_id,journal_reference,posted_at)
    VALUES (v_operation,CONCAT('JRN-TRF-',LEFT(v_hash,32)),v_now);
    SET v_journal = LAST_INSERT_ID();
    INSERT INTO journal_lines (journal_id,gl_account_id,account_id,entry_type,amount,currency)
    VALUES (v_journal,v_source_gl,v_source_id,'DEBIT',p_amount,'NGN'),
           (v_journal,v_dest_gl,v_dest_id,'CREDIT',p_amount,'NGN');

    UPDATE bank_accounts SET available_balance = available_balance - p_amount,
      ledger_balance = ledger_balance - p_amount, updated_at = v_now
      WHERE account_id = v_source_id;
    UPDATE bank_accounts SET available_balance = available_balance + p_amount,
      ledger_balance = ledger_balance + p_amount, updated_at = v_now
      WHERE account_id = v_dest_id;

    INSERT INTO account_balance_snapshots
      (account_id,ledger_balance,available_balance,snapshot_at)
    VALUES (v_source_id,v_source_ledger-p_amount,v_source_available-p_amount,v_now),
           (v_dest_id,v_dest_ledger+p_amount,v_dest_available+p_amount,v_now);

    COMMIT;
    SELECT CONCAT('TRF-',LEFT(v_hash,32)) AS operation_reference,
           p_source_account_number AS source_account,
           p_destination_account_number AS destination_account,
           p_amount AS transferred_amount, 'NGN' AS currency,
           v_journal AS journal_id;
END $$
DELIMITER ;

-- MANUAL TESTS (execute separately, after selecting an ACTIVE/ALLOWED destination):
-- SELECT account_number,account_status,credit_status,currency FROM bank_accounts
-- WHERE account_number <> '9000000001' AND currency='NGN'
--   AND account_status='ACTIVE' AND credit_status='ALLOWED' LIMIT 10;
-- CALL sp_transfer_funds('9000000001','REPLACE_DESTINATION',25000.0000,'ADB-TRF-TEST-0001');
-- SELECT account_number,available_balance,ledger_balance FROM bank_accounts
-- WHERE account_number IN ('9000000001','REPLACE_DESTINATION');
-- Reusing the same idempotency key should fail without moving funds again.
