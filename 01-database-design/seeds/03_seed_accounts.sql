-- Apex Digital Bank | 03 | Accounts | MySQL 8+
-- Prerequisites: run 01_seed_reference_data.sql and 02_seed_customers.sql successfully.
-- Creates 100 primary NGN accounts, 25 additional NGN current accounts,
-- and 10 USD domiciliary accounts (135 total) for ADB-C0001..ADB-C0100.
-- Synthetic account numbers only. Safe to rerun; does not overwrite balances.
-- Opening balances remain zero: real balances must come from balanced journal postings.
USE apex_digital_bank;

-- Check prerequisites BEFORE running the transaction. Expected: 100 customers, 3 schemes.
SELECT COUNT(*) AS seeded_customers FROM customers
 WHERE customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100';
SELECT scheme_code, currency FROM account_schemes
 WHERE scheme_code IN ('SAV_NGN','CUR_NGN','DOM_USD');

START TRANSACTION;

-- 1) One primary savings account per customer.
-- Account numbers 9000000001..9000000100 are reserved for fictional coursework.
INSERT INTO bank_accounts
(customer_id,scheme_id,account_number,account_name,currency,account_status,
 debit_status,credit_status,available_balance,ledger_balance,opened_at,updated_at)
SELECT c.customer_id,s.scheme_id,
 CONCAT('9',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT(c.first_name,' ',c.last_name),'NGN',
 CASE WHEN c.customer_status='DORMANT' THEN 'DORMANT'
      WHEN c.customer_status='RESTRICTED' THEN 'RESTRICTED' ELSE 'ACTIVE' END,
 CASE WHEN c.customer_status IN ('DORMANT','RESTRICTED') OR c.restriction_status='DEBIT_RESTRICTED'
      THEN 'BLOCKED' ELSE 'ALLOWED' END,
 'ALLOWED',0.0000,0.0000,c.onboarding_date,c.onboarding_date
FROM customers c JOIN account_schemes s ON s.scheme_code='SAV_NGN'
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND NOT EXISTS (SELECT 1 FROM bank_accounts a
 WHERE a.account_number=CONCAT('9',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')));

-- 2) Additional current accounts for every fourth customer: 25 accounts.
INSERT INTO bank_accounts
(customer_id,scheme_id,account_number,account_name,currency,account_status,
 debit_status,credit_status,available_balance,ledger_balance,opened_at,updated_at)
SELECT c.customer_id,s.scheme_id,
 CONCAT('8',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT(c.first_name,' ',c.last_name),'NGN',
 CASE WHEN c.customer_status='DORMANT' THEN 'DORMANT'
      WHEN c.customer_status='RESTRICTED' THEN 'RESTRICTED' ELSE 'ACTIVE' END,
 CASE WHEN c.customer_status IN ('DORMANT','RESTRICTED') THEN 'BLOCKED' ELSE 'ALLOWED' END,
 'ALLOWED',0.0000,0.0000,DATE_ADD(c.onboarding_date, INTERVAL 30 DAY),
 DATE_ADD(c.onboarding_date, INTERVAL 30 DAY)
FROM customers c JOIN account_schemes s ON s.scheme_code='CUR_NGN'
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND MOD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),4)=0
AND NOT EXISTS (SELECT 1 FROM bank_accounts a
 WHERE a.account_number=CONCAT('8',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')));

-- 3) USD domiciliary accounts for every tenth customer: 10 accounts.
INSERT INTO bank_accounts
(customer_id,scheme_id,account_number,account_name,currency,account_status,
 debit_status,credit_status,available_balance,ledger_balance,opened_at,updated_at)
SELECT c.customer_id,s.scheme_id,
 CONCAT('7',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT(c.first_name,' ',c.last_name),'USD',
 CASE WHEN c.customer_status='DORMANT' THEN 'DORMANT'
      WHEN c.customer_status='RESTRICTED' THEN 'RESTRICTED' ELSE 'ACTIVE' END,
 CASE WHEN c.customer_status IN ('DORMANT','RESTRICTED') THEN 'BLOCKED' ELSE 'ALLOWED' END,
 'ALLOWED',0.0000,0.0000,DATE_ADD(c.onboarding_date, INTERVAL 60 DAY),
 DATE_ADD(c.onboarding_date, INTERVAL 60 DAY)
FROM customers c JOIN account_schemes s ON s.scheme_code='DOM_USD'
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND MOD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),10)=0
AND NOT EXISTS (SELECT 1 FROM bank_accounts a
 WHERE a.account_number=CONCAT('7',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')));

-- 4) Explicit account ownership records for all synthetic accounts.
INSERT INTO account_holders(account_id,customer_id,ownership_role,is_primary)
SELECT a.account_id,a.customer_id,'PRIMARY',1
FROM bank_accounts a JOIN customers c ON c.customer_id=a.customer_id
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND a.account_number IN (
 CONCAT('9',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT('8',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT('7',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')))
AND NOT EXISTS (SELECT 1 FROM account_holders h
 WHERE h.account_id=a.account_id AND h.customer_id=a.customer_id AND h.is_primary=1);

-- 5) Initial account status audit records.
INSERT INTO account_status_history(account_id,previous_status,new_status,changed_at)
SELECT a.account_id,NULL,a.account_status,a.opened_at
FROM bank_accounts a JOIN customers c ON c.customer_id=a.customer_id
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND a.account_number IN (
 CONCAT('9',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT('8',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT('7',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')))
AND NOT EXISTS (SELECT 1 FROM account_status_history h
 WHERE h.account_id=a.account_id AND h.previous_status IS NULL);

-- 6) Restrictions corresponding to dormant/restricted customer statuses.
INSERT INTO account_restrictions
(account_id,restriction_type,reason_code,is_active,effective_from,effective_to)
SELECT a.account_id,'DEBIT',
 CASE WHEN c.customer_status='DORMANT' THEN 'CUSTOMER_DORMANT' ELSE 'CUSTOMER_RESTRICTED' END,
 1,a.opened_at,NULL
FROM bank_accounts a JOIN customers c ON c.customer_id=a.customer_id
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND c.customer_status IN ('DORMANT','RESTRICTED')
AND a.account_number IN (
 CONCAT('9',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT('8',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')),
 CONCAT('7',LPAD(CAST(SUBSTRING(c.customer_number,6) AS UNSIGNED),9,'0')))
AND NOT EXISTS (SELECT 1 FROM account_restrictions r
 WHERE r.account_id=a.account_id AND r.restriction_type='DEBIT' AND r.is_active=1);

COMMIT;

-- Validation: on an otherwise empty bank_accounts table expect 135 seeded accounts.
SELECT COUNT(*) AS seeded_accounts,
 SUM(currency='NGN') AS ngn_accounts,
 SUM(currency='USD') AS usd_accounts,
 SUM(account_status='ACTIVE') AS active_accounts,
 SUM(account_status='DORMANT') AS dormant_accounts,
 SUM(account_status='RESTRICTED') AS restricted_accounts
FROM bank_accounts WHERE
 (account_number BETWEEN '9000000001' AND '9000000100') OR
 (account_number BETWEEN '8000000001' AND '8000000100') OR
 (account_number BETWEEN '7000000001' AND '7000000100');

SELECT c.customer_number, CONCAT(c.first_name,' ',c.last_name) AS customer_name,
 a.account_number,s.scheme_code,a.currency,a.account_status,
 a.available_balance,a.ledger_balance
FROM bank_accounts a
JOIN customers c ON c.customer_id=a.customer_id
JOIN account_schemes s ON s.scheme_id=a.scheme_id
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
ORDER BY c.customer_number,a.account_number LIMIT 30;

SELECT COUNT(*) AS seeded_primary_holders
FROM account_holders h JOIN bank_accounts a ON a.account_id=h.account_id
WHERE h.ownership_role='PRIMARY' AND h.is_primary=1 AND
 ((a.account_number BETWEEN '9000000001' AND '9000000100') OR
  (a.account_number BETWEEN '8000000001' AND '8000000100') OR
  (a.account_number BETWEEN '7000000001' AND '7000000100'));
