-- Apex Digital Bank | 02 | 100 synthetic customers + KYC | MySQL 8+
-- Run AFTER 01_seed_reference_data.sql. All identity tokens are fake.
-- Uses ADB-C0001...ADB-C0100, synthetic emails under example.test.
-- Rerunnable: existing seed customers and child rows are not duplicated.
USE apex_digital_bank;

DROP TEMPORARY TABLE IF EXISTS adb_seed_numbers;
CREATE TEMPORARY TABLE adb_seed_numbers (n INT PRIMARY KEY);
INSERT INTO adb_seed_numbers(n)
WITH RECURSIVE seq AS (SELECT 1 n UNION ALL SELECT n+1 FROM seq WHERE n<100)
SELECT n FROM seq;

START TRANSACTION;
INSERT INTO customers (
 customer_number,customer_type,title,first_name,middle_name,last_name,date_of_birth,gender,
 marital_status,email,phone_number,alternate_phone_number,residential_address,city,state,
 country,postal_code,nationality,state_of_origin,occupation,employment_status,employer_name,
 annual_income,customer_status,customer_segment,relationship_manager_id,onboarding_channel,
 onboarding_date,bvn_verification_status,nin_verification_status,nin_bvn_linking_status,
 kyc_level,kyc_status,kyc_last_reviewed_at,credit_risk_rating,last_credit_assessment_at,
 aml_risk_rating,is_pep,aml_screening_status,last_aml_screened_at,is_blacklisted,is_deceased,
 is_dormant,restriction_status,created_at,updated_at,created_by,updated_by
)
SELECT
 CONCAT('ADB-C',LPAD(n.n,4,'0')),'INDIVIDUAL',
 CASE WHEN MOD(n.n,2)=0 THEN 'Mr' ELSE 'Ms' END,
 CASE MOD(n.n-1,20) WHEN 0 THEN 'Ada' WHEN 1 THEN 'Chinedu' WHEN 2 THEN 'Zainab' WHEN 3 THEN 'Tunde' WHEN 4 THEN 'Ngozi' WHEN 5 THEN 'Ibrahim' WHEN 6 THEN 'Amaka' WHEN 7 THEN 'Emeka' WHEN 8 THEN 'Aisha' WHEN 9 THEN 'Femi' WHEN 10 THEN 'Chika' WHEN 11 THEN 'Seyi' WHEN 12 THEN 'Hauwa' WHEN 13 THEN 'Obinna' WHEN 14 THEN 'Fatima' WHEN 15 THEN 'Kunle' WHEN 16 THEN 'Ifeoma' WHEN 17 THEN 'Yusuf' WHEN 18 THEN 'Bisi' WHEN 19 THEN 'Nnamdi' END,NULL,CASE MOD(FLOOR((n.n-1)/5),20) WHEN 0 THEN 'Okafor' WHEN 1 THEN 'Adeyemi' WHEN 2 THEN 'Bello' WHEN 3 THEN 'Eze' WHEN 4 THEN 'Musa' WHEN 5 THEN 'Balogun' WHEN 6 THEN 'Nwosu' WHEN 7 THEN 'Abubakar' WHEN 8 THEN 'Ojo' WHEN 9 THEN 'Umeh' WHEN 10 THEN 'Lawal' WHEN 11 THEN 'Ibrahim' WHEN 12 THEN 'Adebayo' WHEN 13 THEN 'Okonkwo' WHEN 14 THEN 'Danladi' WHEN 15 THEN 'Ogunleye' WHEN 16 THEN 'Nwachukwu' WHEN 17 THEN 'Aliyu' WHEN 18 THEN 'Bakare' WHEN 19 THEN 'Ekwueme' END,
 DATE_ADD('1970-01-01',INTERVAL MOD(n.n*137,12000) DAY),
 CASE WHEN MOD(n.n,2)=0 THEN 'MALE' ELSE 'FEMALE' END,
 CASE MOD(n.n,3) WHEN 0 THEN 'MARRIED' WHEN 1 THEN 'SINGLE' ELSE 'DIVORCED' END,
 CONCAT('adb.customer',LPAD(n.n,4,'0'),'@example.test'),
 CONCAT('+234000',LPAD(n.n,7,'0')),NULL,
 CONCAT(n.n,' Synthetic Avenue'),
 CASE MOD(n.n,5) WHEN 0 THEN 'Lagos' WHEN 1 THEN 'Abuja' WHEN 2 THEN 'Ibadan' WHEN 3 THEN 'Port Harcourt' ELSE 'Enugu' END,
 CASE MOD(n.n,5) WHEN 0 THEN 'Lagos' WHEN 1 THEN 'FCT' WHEN 2 THEN 'Oyo' WHEN 3 THEN 'Rivers' ELSE 'Enugu' END,
 'NG','000000','NG',
 CASE MOD(n.n,4) WHEN 0 THEN 'Lagos' WHEN 1 THEN 'Anambra' WHEN 2 THEN 'Kano' ELSE 'Oyo' END,
 CASE MOD(n.n,5) WHEN 0 THEN 'Software Engineer' WHEN 1 THEN 'Teacher' WHEN 2 THEN 'Trader' WHEN 3 THEN 'Accountant' ELSE 'Civil Servant' END,
 CASE WHEN MOD(n.n,10)=0 THEN 'SELF_EMPLOYED' ELSE 'EMPLOYED' END,
 CASE WHEN MOD(n.n,10)=0 THEN 'Self Employed' ELSE 'Apex Synthetic Employers Ltd' END,
 CAST(1200000+n.n*125000 AS DECIMAL(19,4)),
 CASE WHEN MOD(n.n,20)=0 THEN 'DORMANT' WHEN MOD(n.n,17)=0 THEN 'RESTRICTED' ELSE 'ACTIVE' END,
 CASE WHEN MOD(n.n,8)=0 THEN 'AFFLUENT' ELSE 'RETAIL' END,
 (SELECT user_id FROM system_users WHERE username=CASE WHEN MOD(n.n,2)=0 THEN 'adb_rm_01' ELSE 'adb_rm_02' END),
 CASE MOD(n.n,3) WHEN 0 THEN 'MOBILE' WHEN 1 THEN 'WEB' ELSE 'BRANCH' END,
 DATE_ADD('2025-01-01 09:00:00',INTERVAL n.n DAY),
 CASE WHEN MOD(n.n,10)=0 THEN 'PENDING' ELSE 'VERIFIED' END,
 CASE WHEN MOD(n.n,12)=0 THEN 'PENDING' ELSE 'VERIFIED' END,
 CASE WHEN MOD(n.n,10)=0 OR MOD(n.n,12)=0 THEN 'PENDING' ELSE 'LINKED' END,
 CASE WHEN MOD(n.n,10)=0 OR MOD(n.n,12)=0 THEN 'TIER_1' WHEN MOD(n.n,3)=0 THEN 'TIER_3' ELSE 'TIER_2' END,
 CASE WHEN MOD(n.n,10)=0 OR MOD(n.n,12)=0 THEN 'PENDING' ELSE 'VERIFIED' END,
 '2026-10-01 12:00:00',
 CASE WHEN MOD(n.n,11)=0 THEN 'HIGH' WHEN MOD(n.n,4)=0 THEN 'MEDIUM' ELSE 'LOW' END,
 '2026-10-02 12:00:00',
 CASE WHEN MOD(n.n,17)=0 THEN 'HIGH' WHEN MOD(n.n,5)=0 THEN 'MEDIUM' ELSE 'LOW' END,
 CASE WHEN MOD(n.n,29)=0 THEN 1 ELSE 0 END,
 CASE WHEN MOD(n.n,17)=0 THEN 'REVIEW' ELSE 'CLEAR' END,
 '2026-10-03 12:00:00',
 CASE WHEN MOD(n.n,37)=0 THEN 1 ELSE 0 END,0,
 CASE WHEN MOD(n.n,20)=0 THEN 1 ELSE 0 END,
 CASE WHEN MOD(n.n,17)=0 THEN 'DEBIT_RESTRICTED' ELSE 'NONE' END,
 '2025-01-01 09:00:00','2026-10-03 12:00:00',
 (SELECT user_id FROM system_users WHERE username='adb_seed_admin'),
 (SELECT user_id FROM system_users WHERE username='adb_seed_admin')
FROM adb_seed_numbers n
WHERE NOT EXISTS (SELECT 1 FROM customers c WHERE c.customer_number=CONCAT('ADB-C',LPAD(n.n,4,'0')));

-- BVN/NIN verification records contain opaque synthetic tokens, not real identity numbers.
INSERT INTO customer_identity_verifications
(customer_id,identity_type,identifier_token,verification_status,provider_reference,verified_at)
SELECT c.customer_id,kind.identity_type,
 CONCAT('SYNTHETIC-',kind.identity_type,'-',c.customer_number),
 CASE WHEN kind.identity_type='BVN' THEN c.bvn_verification_status ELSE c.nin_verification_status END,
 CONCAT('SIM-',kind.identity_type,'-',c.customer_number),
 CASE WHEN (kind.identity_type='BVN' AND c.bvn_verification_status='VERIFIED') OR
           (kind.identity_type='NIN' AND c.nin_verification_status='VERIFIED')
      THEN '2026-10-01 12:00:00' ELSE NULL END
FROM customers c CROSS JOIN (SELECT 'BVN' identity_type UNION ALL SELECT 'NIN') kind
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND NOT EXISTS (SELECT 1 FROM customer_identity_verifications v
 WHERE v.customer_id=c.customer_id AND v.identity_type=kind.identity_type
 AND v.identifier_token=CONCAT('SYNTHETIC-',kind.identity_type,'-',c.customer_number));

INSERT INTO customer_identity_links
(customer_id,bvn_verification_id,nin_verification_id,linking_status,linked_at)
SELECT c.customer_id,b.verification_id,ni.verification_id,c.nin_bvn_linking_status,
 CASE WHEN c.nin_bvn_linking_status='LINKED' THEN '2026-10-02 12:00:00' ELSE NULL END
FROM customers c
JOIN customer_identity_verifications b ON b.customer_id=c.customer_id AND b.identity_type='BVN'
 AND b.identifier_token=CONCAT('SYNTHETIC-BVN-',c.customer_number)
JOIN customer_identity_verifications ni ON ni.customer_id=c.customer_id AND ni.identity_type='NIN'
 AND ni.identifier_token=CONCAT('SYNTHETIC-NIN-',c.customer_number)
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND NOT EXISTS (SELECT 1 FROM customer_identity_links l WHERE l.customer_id=c.customer_id
 AND l.bvn_verification_id=b.verification_id AND l.nin_verification_id=ni.verification_id);

INSERT INTO customer_risk_assessments
(customer_id,risk_type,risk_rating,assessment_version,assessed_at)
SELECT c.customer_id,k.risk_type,
 CASE WHEN k.risk_type='AML' THEN c.aml_risk_rating ELSE c.credit_risk_rating END,
 'SEED-V1','2026-10-03 12:00:00'
FROM customers c CROSS JOIN (SELECT 'AML' risk_type UNION ALL SELECT 'CREDIT') k
WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND NOT EXISTS (SELECT 1 FROM customer_risk_assessments a WHERE a.customer_id=c.customer_id
 AND a.risk_type=k.risk_type AND a.assessment_version='SEED-V1');

INSERT INTO customer_status_history(customer_id,old_status,new_status,reason,changed_at)
SELECT c.customer_id,NULL,c.customer_status,'Synthetic customer onboarding',c.onboarding_date
FROM customers c WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100'
AND NOT EXISTS (SELECT 1 FROM customer_status_history h WHERE h.customer_id=c.customer_id
 AND h.reason='Synthetic customer onboarding');
COMMIT;
DROP TEMPORARY TABLE IF EXISTS adb_seed_numbers;

-- Validation: expected 100 customers, 200 identity records, 100 links,
-- 200 risk assessments, and 100 status-history rows on a fresh baseline.
SELECT COUNT(*) AS seeded_customers FROM customers
 WHERE customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100';
SELECT COUNT(*) AS seeded_verifications FROM customer_identity_verifications
 WHERE identifier_token LIKE 'SYNTHETIC-%-ADB-C%';
SELECT COUNT(*) AS seeded_links FROM customer_identity_links l JOIN customers c ON c.customer_id=l.customer_id
 WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100';
SELECT COUNT(*) AS seeded_risk_assessments FROM customer_risk_assessments a JOIN customers c ON c.customer_id=a.customer_id
 WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100' AND a.assessment_version='SEED-V1';
SELECT COUNT(*) AS seeded_status_history FROM customer_status_history h JOIN customers c ON c.customer_id=h.customer_id
 WHERE c.customer_number BETWEEN 'ADB-C0001' AND 'ADB-C0100' AND h.reason='Synthetic customer onboarding';
