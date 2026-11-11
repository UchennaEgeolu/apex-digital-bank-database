-- Apex Digital Bank | 01 | Reference data | MySQL 8+
-- Run AFTER the baseline schema. Safe to rerun; no tables are dropped.
USE apex_digital_bank;
START TRANSACTION;

INSERT INTO system_users (username,role,is_active,created_at) VALUES
('adb_seed_admin','ADMIN',1,NOW(6)),('adb_rm_01','RELATIONSHIP_MANAGER',1,NOW(6)),
('adb_rm_02','RELATIONSHIP_MANAGER',1,NOW(6)),('adb_compliance','COMPLIANCE',1,NOW(6))
ON DUPLICATE KEY UPDATE username=VALUES(username);

INSERT INTO account_types(type_code,type_name) VALUES
('SAV','Savings Account'),('CUR','Current Account'),('DOM','Domiciliary Account')
ON DUPLICATE KEY UPDATE type_name=VALUES(type_name);

INSERT INTO transaction_channels(channel_code,channel_name) VALUES
('MOBILE','Mobile Banking'),('WEB','Internet Banking'),('USSD','USSD Banking'),
('ATM','Automated Teller Machine'),('BRANCH','Branch'),('API','Partner API'),('POS','Point of Sale')
ON DUPLICATE KEY UPDATE channel_name=VALUES(channel_name);

-- Already seeded by baseline DDL. Do not overwrite existing IDs or meanings.
INSERT INTO transaction_statuses(status_code,description,is_terminal) VALUES
('INITIATED','Request accepted',0),('PENDING','Awaiting processing',0),
('PROCESSING','Processing',0),('SUCCESSFUL','Completed',1),
('FAILED','Failed',1),('REVERSED','Reversal registered',1),('CANCELLED','Cancelled',1)
ON DUPLICATE KEY UPDATE status_code=VALUES(status_code);

INSERT INTO gl_accounts(gl_code,gl_name,account_class) VALUES
('100100','Cash and Bank Settlement','ASSET'),
('100200','Interbank Clearing','ASSET'),
('200100','Customer Savings Deposits','LIABILITY'),
('200200','Customer Current Deposits','LIABILITY'),
('200300','Customer Domiciliary Deposits','LIABILITY'),
('110100','Customer Loan Principal','ASSET'),
('400100','Interest Income','INCOME'),
('500100','Interest Expense','EXPENSE')
ON DUPLICATE KEY UPDATE gl_name=VALUES(gl_name),account_class=VALUES(account_class);

INSERT INTO document_types(type_code,type_name,requires_verification) VALUES
('NIN_SLIP','National Identity Number Slip',1),('PASSPORT','International Passport',1),
('DRIVERS_LICENSE','Drivers Licence',1),('UTILITY_BILL','Utility Bill',1),
('PASSPORT_PHOTO','Passport Photograph',0),('SIGNATURE','Specimen Signature',1)
ON DUPLICATE KEY UPDATE type_name=VALUES(type_name),requires_verification=VALUES(requires_verification);

INSERT INTO loan_products(product_code,product_name,interest_rate,maximum_tenor,maximum_amount,is_active) VALUES
('SAL_ADV','Salary Advance',24.0000,12,1500000.0000,1),
('PERSONAL','Personal Loan',21.0000,36,10000000.0000,1),
('SME_WORK','SME Working Capital',26.0000,24,25000000.0000,1)
ON DUPLICATE KEY UPDATE product_name=VALUES(product_name);

INSERT INTO transaction_monitoring_rules(rule_code,rule_name,is_active) VALUES
('HIGH_VALUE','High Value Transfer',1),('RAPID_MOVEMENT','Rapid Funds Movement',1),
('STRUCTURING','Possible Transaction Structuring',1),('NEW_ACCOUNT','New Account Large Transaction',1)
ON DUPLICATE KEY UPDATE rule_name=VALUES(rule_name);

INSERT INTO account_schemes(account_type_id,scheme_code,scheme_name,currency,minimum_balance,is_active)
SELECT t.account_type_id,s.scheme_code,s.scheme_name,s.currency,s.minimum_balance,1
FROM (
SELECT 'SAV' type_code,'SAV_NGN' scheme_code,'Everyday Savings' scheme_name,'NGN' currency,0.0000 minimum_balance
UNION ALL SELECT 'CUR','CUR_NGN','Business Current','NGN',1000.0000
UNION ALL SELECT 'DOM','DOM_USD','USD Domiciliary','USD',0.0000
UNION ALL SELECT 'DOM','DOM_GBP','GBP Domiciliary','GBP',0.0000
UNION ALL SELECT 'DOM','DOM_EUR','EUR Domiciliary','EUR',0.0000
) s JOIN account_types t ON t.type_code=s.type_code
ON DUPLICATE KEY UPDATE scheme_name=VALUES(scheme_name);
COMMIT;

-- Sanity checks
SELECT 'system_users' table_name,COUNT(*) rows_present FROM system_users
UNION ALL SELECT 'account_types',COUNT(*) FROM account_types
UNION ALL SELECT 'account_schemes',COUNT(*) FROM account_schemes
UNION ALL SELECT 'transaction_statuses',COUNT(*) FROM transaction_statuses
UNION ALL SELECT 'loan_products',COUNT(*) FROM loan_products;
