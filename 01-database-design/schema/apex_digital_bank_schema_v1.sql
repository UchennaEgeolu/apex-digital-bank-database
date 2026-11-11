-- APEX DIGITAL BANK | MySQL 8.0+ | baseline DDL
-- Designed for synthetic data and educational assessment.
-- IMPORTANT: cross-table banking invariants require separate posting procedures.
CREATE DATABASE IF NOT EXISTS apex_digital_bank CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE apex_digital_bank;

-- Administration: system_users
CREATE TABLE `system_users` (
  `user_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `username` VARCHAR(80),
  `role` VARCHAR(40),
  `is_active` BOOLEAN,
  `created_at` DATETIME(6),
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_system_users_username` (`username`)
) ENGINE=InnoDB;

-- Accounts: account_types
CREATE TABLE `account_types` (
  `account_type_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_code` VARCHAR(20),
  `type_name` VARCHAR(80),
  PRIMARY KEY (`account_type_id`),
  UNIQUE KEY `uq_account_types_type_code` (`type_code`)
) ENGINE=InnoDB;

-- Transactions: transaction_channels
CREATE TABLE `transaction_channels` (
  `channel_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `channel_code` VARCHAR(30),
  `channel_name` VARCHAR(80),
  PRIMARY KEY (`channel_id`),
  UNIQUE KEY `uq_transaction_channels_channel_code` (`channel_code`)
) ENGINE=InnoDB;

-- Transactions: transaction_statuses
CREATE TABLE `transaction_statuses` (
  `status_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `status_code` VARCHAR(30),
  `description` VARCHAR(255),
  `is_terminal` BOOLEAN,
  PRIMARY KEY (`status_id`),
  UNIQUE KEY `uq_transaction_statuses_status_code` (`status_code`)
) ENGINE=InnoDB;

-- Ledger: gl_accounts
CREATE TABLE `gl_accounts` (
  `gl_account_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `gl_code` VARCHAR(30),
  `gl_name` VARCHAR(100),
  `account_class` VARCHAR(30),
  PRIMARY KEY (`gl_account_id`),
  UNIQUE KEY `uq_gl_accounts_gl_code` (`gl_code`)
) ENGINE=InnoDB;

-- Documents: document_types
CREATE TABLE `document_types` (
  `document_type_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `type_code` VARCHAR(30),
  `type_name` VARCHAR(100),
  `requires_verification` BOOLEAN,
  PRIMARY KEY (`document_type_id`),
  UNIQUE KEY `uq_document_types_type_code` (`type_code`)
) ENGINE=InnoDB;

-- Loans: loan_products
CREATE TABLE `loan_products` (
  `product_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_code` VARCHAR(30),
  `product_name` VARCHAR(100),
  `interest_rate` DECIMAL(9,4),
  `maximum_tenor` INT,
  `maximum_amount` DECIMAL(19,4),
  `is_active` BOOLEAN,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `uq_loan_products_product_code` (`product_code`)
) ENGINE=InnoDB;

-- AML & Fraud: watchlist_sources
CREATE TABLE `watchlist_sources` (
  `source_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `source_name` VARCHAR(100),
  `source_type` VARCHAR(40),
  `source_url` VARCHAR(255),
  `last_updated_at` DATETIME(6),
  PRIMARY KEY (`source_id`)
) ENGINE=InnoDB;

-- AML & Fraud: transaction_monitoring_rules
CREATE TABLE `transaction_monitoring_rules` (
  `rule_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `rule_code` VARCHAR(30),
  `rule_name` VARCHAR(100),
  `is_active` BOOLEAN,
  PRIMARY KEY (`rule_id`),
  UNIQUE KEY `uq_transaction_monitoring_rules_rule_code` (`rule_code`)
) ENGINE=InnoDB;

-- Customer & KYC: customers
CREATE TABLE `customers` (
  `customer_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_number` VARCHAR(30),
  `customer_type` VARCHAR(20),
  `title` VARCHAR(20),
  `first_name` VARCHAR(100),
  `middle_name` VARCHAR(100),
  `last_name` VARCHAR(100),
  `date_of_birth` DATE,
  `gender` VARCHAR(30),
  `marital_status` VARCHAR(30),
  `email` VARCHAR(150),
  `phone_number` VARCHAR(25),
  `alternate_phone_number` VARCHAR(25),
  `residential_address` VARCHAR(255),
  `city` VARCHAR(100),
  `state` VARCHAR(100),
  `country` CHAR(2),
  `postal_code` VARCHAR(20),
  `nationality` CHAR(2),
  `state_of_origin` VARCHAR(100),
  `occupation` VARCHAR(100),
  `employment_status` VARCHAR(40),
  `employer_name` VARCHAR(150),
  `annual_income` DECIMAL(19,4),
  `customer_status` VARCHAR(30),
  `customer_segment` VARCHAR(40),
  `relationship_manager_id` BIGINT UNSIGNED,
  `onboarding_channel` VARCHAR(30),
  `onboarding_date` DATETIME(6),
  `bvn_verification_status` VARCHAR(30),
  `nin_verification_status` VARCHAR(30),
  `nin_bvn_linking_status` VARCHAR(30),
  `kyc_level` VARCHAR(20),
  `kyc_status` VARCHAR(30),
  `kyc_last_reviewed_at` DATETIME(6),
  `credit_risk_rating` VARCHAR(20),
  `last_credit_assessment_at` DATETIME(6),
  `aml_risk_rating` VARCHAR(20),
  `is_pep` BOOLEAN,
  `aml_screening_status` VARCHAR(30),
  `last_aml_screened_at` DATETIME(6),
  `is_blacklisted` BOOLEAN,
  `is_deceased` BOOLEAN,
  `is_dormant` BOOLEAN,
  `restriction_status` VARCHAR(30),
  `created_at` DATETIME(6),
  `updated_at` DATETIME(6),
  `created_by` BIGINT UNSIGNED,
  `updated_by` BIGINT UNSIGNED,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `uq_customers_customer_number` (`customer_number`),
  CONSTRAINT `fk_customers_relationship_manager_id` FOREIGN KEY (`relationship_manager_id`) REFERENCES `system_users` (`user_id`),
  CONSTRAINT `fk_customers_created_by` FOREIGN KEY (`created_by`) REFERENCES `system_users` (`user_id`),
  CONSTRAINT `fk_customers_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `system_users` (`user_id`)
) ENGINE=InnoDB;

-- Accounts: account_schemes
CREATE TABLE `account_schemes` (
  `scheme_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_type_id` BIGINT UNSIGNED,
  `scheme_code` VARCHAR(20),
  `scheme_name` VARCHAR(100),
  `currency` CHAR(3),
  `minimum_balance` DECIMAL(19,4),
  `is_active` BOOLEAN,
  PRIMARY KEY (`scheme_id`),
  CONSTRAINT `fk_account_schemes_account_type_id` FOREIGN KEY (`account_type_id`) REFERENCES `account_types` (`account_type_id`),
  UNIQUE KEY `uq_account_schemes_scheme_code` (`scheme_code`)
) ENGINE=InnoDB;

-- Loans: loan_eligibility_rules
CREATE TABLE `loan_eligibility_rules` (
  `rule_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `product_id` BIGINT UNSIGNED,
  `rule_code` VARCHAR(40),
  `rule_version` VARCHAR(30),
  `operator` VARCHAR(10),
  `threshold_value` DECIMAL(19,4),
  `is_active` BOOLEAN,
  PRIMARY KEY (`rule_id`),
  CONSTRAINT `fk_loan_eligibility_rules_product_id` FOREIGN KEY (`product_id`) REFERENCES `loan_products` (`product_id`)
) ENGINE=InnoDB;

-- AML & Fraud: watchlist_entries
CREATE TABLE `watchlist_entries` (
  `entry_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `source_id` BIGINT UNSIGNED,
  `entity_name` VARCHAR(200),
  `entity_type` VARCHAR(30),
  `risk_category` VARCHAR(30),
  `listing_status` VARCHAR(30),
  PRIMARY KEY (`entry_id`),
  CONSTRAINT `fk_watchlist_entries_source_id` FOREIGN KEY (`source_id`) REFERENCES `watchlist_sources` (`source_id`)
) ENGINE=InnoDB;

-- Customer & KYC: customer_relationships
CREATE TABLE `customer_relationships` (
  `relationship_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `related_customer_id` BIGINT UNSIGNED,
  `relationship_type` VARCHAR(40),
  `created_at` DATETIME(6),
  PRIMARY KEY (`relationship_id`),
  CONSTRAINT `fk_customer_relationships_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_customer_relationships_related_customer_id` FOREIGN KEY (`related_customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB;

-- Customer & KYC: customer_status_history
CREATE TABLE `customer_status_history` (
  `history_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `old_status` VARCHAR(30),
  `new_status` VARCHAR(30),
  `reason` VARCHAR(255),
  `changed_at` DATETIME(6),
  PRIMARY KEY (`history_id`),
  CONSTRAINT `fk_customer_status_history_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB;

-- Customer & KYC: customer_identity_verifications
CREATE TABLE `customer_identity_verifications` (
  `verification_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `identity_type` VARCHAR(20),
  `identifier_token` VARCHAR(128),
  `verification_status` VARCHAR(30),
  `provider_reference` VARCHAR(80),
  `verified_at` DATETIME(6),
  PRIMARY KEY (`verification_id`),
  CONSTRAINT `fk_customer_identity_verifications_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB;

-- Customer & KYC: customer_risk_assessments
CREATE TABLE `customer_risk_assessments` (
  `risk_assessment_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `risk_type` VARCHAR(30),
  `risk_rating` VARCHAR(20),
  `assessment_version` VARCHAR(30),
  `assessed_at` DATETIME(6),
  PRIMARY KEY (`risk_assessment_id`),
  CONSTRAINT `fk_customer_risk_assessments_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB;

-- Accounts: bank_accounts
CREATE TABLE `bank_accounts` (
  `account_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `scheme_id` BIGINT UNSIGNED,
  `account_number` VARCHAR(20),
  `account_name` VARCHAR(160),
  `currency` CHAR(3),
  `account_status` VARCHAR(30),
  `debit_status` VARCHAR(30),
  `credit_status` VARCHAR(30),
  `available_balance` DECIMAL(19,4),
  `ledger_balance` DECIMAL(19,4),
  `opened_at` DATETIME(6),
  `updated_at` DATETIME(6),
  PRIMARY KEY (`account_id`),
  CONSTRAINT `fk_bank_accounts_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_bank_accounts_scheme_id` FOREIGN KEY (`scheme_id`) REFERENCES `account_schemes` (`scheme_id`),
  UNIQUE KEY `uq_bank_accounts_account_number` (`account_number`)
) ENGINE=InnoDB;

-- Loans: loan_eligibility_assessments
CREATE TABLE `loan_eligibility_assessments` (
  `assessment_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `product_id` BIGINT UNSIGNED,
  `requested_amount` DECIMAL(19,4),
  `monthly_income` DECIMAL(19,4),
  `debt_to_income_ratio` DECIMAL(7,4),
  `credit_score` INT,
  `eligibility_status` VARCHAR(30),
  `assessed_at` DATETIME(6),
  PRIMARY KEY (`assessment_id`),
  CONSTRAINT `fk_loan_eligibility_assessments_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_loan_eligibility_assessments_product_id` FOREIGN KEY (`product_id`) REFERENCES `loan_products` (`product_id`)
) ENGINE=InnoDB;

-- Loans: customer_credit_profiles
CREATE TABLE `customer_credit_profiles` (
  `profile_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `bureau_reference` VARCHAR(80),
  `credit_score` INT,
  `total_outstanding_debt` DECIMAL(19,4),
  `assessed_at` DATETIME(6),
  PRIMARY KEY (`profile_id`),
  CONSTRAINT `fk_customer_credit_profiles_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB;

-- AML & Fraud: watchlist_identifiers
CREATE TABLE `watchlist_identifiers` (
  `identifier_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `entry_id` BIGINT UNSIGNED,
  `identifier_type` VARCHAR(30),
  `identifier_token` VARCHAR(128),
  PRIMARY KEY (`identifier_id`),
  CONSTRAINT `fk_watchlist_identifiers_entry_id` FOREIGN KEY (`entry_id`) REFERENCES `watchlist_entries` (`entry_id`)
) ENGINE=InnoDB;

-- AML & Fraud: customer_screenings
CREATE TABLE `customer_screenings` (
  `screening_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `screening_type` VARCHAR(30),
  `screening_status` VARCHAR(30),
  `screened_at` DATETIME(6),
  PRIMARY KEY (`screening_id`),
  CONSTRAINT `fk_customer_screenings_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB;

-- Customer & KYC: customer_identity_links
CREATE TABLE `customer_identity_links` (
  `link_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `bvn_verification_id` BIGINT UNSIGNED,
  `nin_verification_id` BIGINT UNSIGNED,
  `linking_status` VARCHAR(30),
  `linked_at` DATETIME(6),
  PRIMARY KEY (`link_id`),
  CONSTRAINT `fk_customer_identity_links_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_customer_identity_links_bvn_verification_id` FOREIGN KEY (`bvn_verification_id`) REFERENCES `customer_identity_verifications` (`verification_id`),
  CONSTRAINT `fk_customer_identity_links_nin_verification_id` FOREIGN KEY (`nin_verification_id`) REFERENCES `customer_identity_verifications` (`verification_id`)
) ENGINE=InnoDB;

-- Accounts: account_holders
CREATE TABLE `account_holders` (
  `holder_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` BIGINT UNSIGNED,
  `customer_id` BIGINT UNSIGNED,
  `ownership_role` VARCHAR(40),
  `is_primary` BOOLEAN,
  PRIMARY KEY (`holder_id`),
  CONSTRAINT `fk_account_holders_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_account_holders_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB;

-- Accounts: account_restrictions
CREATE TABLE `account_restrictions` (
  `restriction_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` BIGINT UNSIGNED,
  `restriction_type` VARCHAR(30),
  `reason_code` VARCHAR(60),
  `is_active` BOOLEAN,
  `effective_from` DATETIME(6),
  `effective_to` DATETIME(6),
  PRIMARY KEY (`restriction_id`),
  CONSTRAINT `fk_account_restrictions_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `chk_restriction_dates` CHECK (`effective_to` IS NULL OR `effective_to` >= `effective_from`)
) ENGINE=InnoDB;

-- Accounts: account_status_history
CREATE TABLE `account_status_history` (
  `history_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` BIGINT UNSIGNED,
  `previous_status` VARCHAR(30),
  `new_status` VARCHAR(30),
  `changed_at` DATETIME(6),
  PRIMARY KEY (`history_id`),
  CONSTRAINT `fk_account_status_history_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`)
) ENGINE=InnoDB;

-- Transactions: financial_operations
CREATE TABLE `financial_operations` (
  `operation_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `operation_reference` VARCHAR(64),
  `operation_type` VARCHAR(30),
  `channel_id` BIGINT UNSIGNED,
  `source_account_id` BIGINT UNSIGNED,
  `destination_account_id` BIGINT UNSIGNED,
  `total_amount` DECIMAL(19,4),
  `currency` CHAR(3),
  `idempotency_key` VARCHAR(100),
  `initiated_at` DATETIME(6),
  PRIMARY KEY (`operation_id`),
  UNIQUE KEY `uq_financial_operations_operation_reference` (`operation_reference`),
  CONSTRAINT `fk_financial_operations_channel_id` FOREIGN KEY (`channel_id`) REFERENCES `transaction_channels` (`channel_id`),
  CONSTRAINT `fk_financial_operations_source_account_id` FOREIGN KEY (`source_account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_financial_operations_destination_account_id` FOREIGN KEY (`destination_account_id`) REFERENCES `bank_accounts` (`account_id`),
  UNIQUE KEY `uq_financial_operations_idempotency_key` (`idempotency_key`)
) ENGINE=InnoDB;

-- Ledger: account_balance_snapshots
CREATE TABLE `account_balance_snapshots` (
  `snapshot_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` BIGINT UNSIGNED,
  `ledger_balance` DECIMAL(19,4),
  `available_balance` DECIMAL(19,4),
  `snapshot_at` DATETIME(6),
  PRIMARY KEY (`snapshot_id`),
  CONSTRAINT `fk_account_balance_snapshots_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`)
) ENGINE=InnoDB;

-- Documents: customer_documents
CREATE TABLE `customer_documents` (
  `document_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `account_id` BIGINT UNSIGNED,
  `document_type_id` BIGINT UNSIGNED,
  `document_name` VARCHAR(255),
  `storage_path` VARCHAR(500),
  `checksum` VARCHAR(128),
  `verification_status` VARCHAR(30),
  `uploaded_at` DATETIME(6),
  PRIMARY KEY (`document_id`),
  CONSTRAINT `fk_customer_documents_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_customer_documents_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_customer_documents_document_type_id` FOREIGN KEY (`document_type_id`) REFERENCES `document_types` (`document_type_id`)
) ENGINE=InnoDB;

-- Loans: loan_eligibility_rule_results
CREATE TABLE `loan_eligibility_rule_results` (
  `result_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assessment_id` BIGINT UNSIGNED,
  `rule_id` BIGINT UNSIGNED,
  `passed` BOOLEAN,
  `reason_code` VARCHAR(50),
  PRIMARY KEY (`result_id`),
  CONSTRAINT `fk_loan_eligibility_rule_results_assessment_id` FOREIGN KEY (`assessment_id`) REFERENCES `loan_eligibility_assessments` (`assessment_id`),
  CONSTRAINT `fk_loan_eligibility_rule_results_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `loan_eligibility_rules` (`rule_id`)
) ENGINE=InnoDB;

-- Loans: loan_applications
CREATE TABLE `loan_applications` (
  `application_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `customer_id` BIGINT UNSIGNED,
  `product_id` BIGINT UNSIGNED,
  `assessment_id` BIGINT UNSIGNED,
  `requested_amount` DECIMAL(19,4),
  `application_status` VARCHAR(30),
  `applied_at` DATETIME(6),
  PRIMARY KEY (`application_id`),
  CONSTRAINT `fk_loan_applications_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_loan_applications_product_id` FOREIGN KEY (`product_id`) REFERENCES `loan_products` (`product_id`),
  CONSTRAINT `fk_loan_applications_assessment_id` FOREIGN KEY (`assessment_id`) REFERENCES `loan_eligibility_assessments` (`assessment_id`)
) ENGINE=InnoDB;

-- AML & Fraud: screening_matches
CREATE TABLE `screening_matches` (
  `match_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `screening_id` BIGINT UNSIGNED,
  `entry_id` BIGINT UNSIGNED,
  `match_score` DECIMAL(6,3),
  `review_status` VARCHAR(30),
  PRIMARY KEY (`match_id`),
  CONSTRAINT `fk_screening_matches_screening_id` FOREIGN KEY (`screening_id`) REFERENCES `customer_screenings` (`screening_id`),
  CONSTRAINT `fk_screening_matches_entry_id` FOREIGN KEY (`entry_id`) REFERENCES `watchlist_entries` (`entry_id`)
) ENGINE=InnoDB;

-- Transactions: transactions
CREATE TABLE `transactions` (
  `transaction_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `transaction_reference` VARCHAR(64),
  `operation_id` BIGINT UNSIGNED,
  `account_id` BIGINT UNSIGNED,
  `status_id` BIGINT UNSIGNED,
  `direction` VARCHAR(10),
  `transaction_type` VARCHAR(30),
  `amount` DECIMAL(19,4),
  `currency` CHAR(3),
  `narration` VARCHAR(500),
  `external_reference` VARCHAR(100),
  `reversal_of_transaction_id` BIGINT UNSIGNED,
  `transaction_date` DATETIME(6),
  `created_at` DATETIME(6),
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `uq_transactions_transaction_reference` (`transaction_reference`),
  CONSTRAINT `fk_transactions_operation_id` FOREIGN KEY (`operation_id`) REFERENCES `financial_operations` (`operation_id`),
  CONSTRAINT `fk_transactions_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_transactions_status_id` FOREIGN KEY (`status_id`) REFERENCES `transaction_statuses` (`status_id`),
  CONSTRAINT `fk_transactions_reversal_of_transaction_id` FOREIGN KEY (`reversal_of_transaction_id`) REFERENCES `transactions` (`transaction_id`),
  CONSTRAINT `chk_transactions_positive` CHECK (`amount` > 0),
  CONSTRAINT `chk_transactions_direction` CHECK (`direction` IN ('INFLOW','OUTFLOW')),
  KEY `idx_transactions_account_date` (`account_id`, `transaction_date`)
) ENGINE=InnoDB;

-- Ledger: journal_headers
CREATE TABLE `journal_headers` (
  `journal_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `operation_id` BIGINT UNSIGNED,
  `journal_reference` VARCHAR(64),
  `posted_at` DATETIME(6),
  PRIMARY KEY (`journal_id`),
  CONSTRAINT `fk_journal_headers_operation_id` FOREIGN KEY (`operation_id`) REFERENCES `financial_operations` (`operation_id`),
  UNIQUE KEY `uq_journal_headers_journal_reference` (`journal_reference`)
) ENGINE=InnoDB;

-- Documents: account_mandates
CREATE TABLE `account_mandates` (
  `mandate_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `account_id` BIGINT UNSIGNED,
  `document_id` BIGINT UNSIGNED,
  `mandate_type` VARCHAR(30),
  `signing_rule` VARCHAR(80),
  `approval_status` VARCHAR(30),
  `effective_from` DATETIME(6),
  `effective_to` DATETIME(6),
  PRIMARY KEY (`mandate_id`),
  CONSTRAINT `fk_account_mandates_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_account_mandates_document_id` FOREIGN KEY (`document_id`) REFERENCES `customer_documents` (`document_id`)
) ENGINE=InnoDB;

-- Loans: loans
CREATE TABLE `loans` (
  `loan_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `application_id` BIGINT UNSIGNED,
  `customer_id` BIGINT UNSIGNED,
  `account_id` BIGINT UNSIGNED,
  `principal_amount` DECIMAL(19,4),
  `outstanding_balance` DECIMAL(19,4),
  `interest_rate` DECIMAL(9,4),
  `loan_status` VARCHAR(30),
  `disbursed_at` DATETIME(6),
  PRIMARY KEY (`loan_id`),
  CONSTRAINT `fk_loans_application_id` FOREIGN KEY (`application_id`) REFERENCES `loan_applications` (`application_id`),
  CONSTRAINT `fk_loans_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_loans_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`)
) ENGINE=InnoDB;

-- AML & Fraud: aml_alerts
CREATE TABLE `aml_alerts` (
  `alert_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `match_id` BIGINT UNSIGNED,
  `severity` VARCHAR(20),
  `alert_status` VARCHAR(30),
  `created_at` DATETIME(6),
  PRIMARY KEY (`alert_id`),
  CONSTRAINT `fk_aml_alerts_match_id` FOREIGN KEY (`match_id`) REFERENCES `screening_matches` (`match_id`)
) ENGINE=InnoDB;

-- Transactions: transaction_status_history
CREATE TABLE `transaction_status_history` (
  `history_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `transaction_id` BIGINT UNSIGNED,
  `status_id` BIGINT UNSIGNED,
  `reason_code` VARCHAR(50),
  `changed_at` DATETIME(6),
  PRIMARY KEY (`history_id`),
  CONSTRAINT `fk_transaction_status_history_transaction_id` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`),
  CONSTRAINT `fk_transaction_status_history_status_id` FOREIGN KEY (`status_id`) REFERENCES `transaction_statuses` (`status_id`)
) ENGINE=InnoDB;

-- Ledger: journal_lines
CREATE TABLE `journal_lines` (
  `line_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `journal_id` BIGINT UNSIGNED,
  `gl_account_id` BIGINT UNSIGNED,
  `account_id` BIGINT UNSIGNED,
  `entry_type` VARCHAR(6),
  `amount` DECIMAL(19,4),
  `currency` CHAR(3),
  PRIMARY KEY (`line_id`),
  CONSTRAINT `fk_journal_lines_journal_id` FOREIGN KEY (`journal_id`) REFERENCES `journal_headers` (`journal_id`),
  CONSTRAINT `fk_journal_lines_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `gl_accounts` (`gl_account_id`),
  CONSTRAINT `fk_journal_lines_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `chk_journal_positive` CHECK (`amount` > 0),
  CONSTRAINT `chk_journal_entry_type` CHECK (`entry_type` IN ('DEBIT','CREDIT'))
) ENGINE=InnoDB;

-- Documents: mandate_signatories
CREATE TABLE `mandate_signatories` (
  `signatory_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `mandate_id` BIGINT UNSIGNED,
  `customer_id` BIGINT UNSIGNED,
  `signing_role` VARCHAR(40),
  `signing_priority` INT,
  `is_active` BOOLEAN,
  PRIMARY KEY (`signatory_id`),
  CONSTRAINT `fk_mandate_signatories_mandate_id` FOREIGN KEY (`mandate_id`) REFERENCES `account_mandates` (`mandate_id`),
  CONSTRAINT `fk_mandate_signatories_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB;

-- Loans: loan_repayment_schedules
CREATE TABLE `loan_repayment_schedules` (
  `schedule_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `loan_id` BIGINT UNSIGNED,
  `due_date` DATE,
  `principal_due` DECIMAL(19,4),
  `interest_due` DECIMAL(19,4),
  `payment_status` VARCHAR(30),
  PRIMARY KEY (`schedule_id`),
  CONSTRAINT `fk_loan_repayment_schedules_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`loan_id`)
) ENGINE=InnoDB;

-- Loans: loan_repayments
CREATE TABLE `loan_repayments` (
  `repayment_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `loan_id` BIGINT UNSIGNED,
  `operation_id` BIGINT UNSIGNED,
  `amount_paid` DECIMAL(19,4),
  `paid_at` DATETIME(6),
  PRIMARY KEY (`repayment_id`),
  CONSTRAINT `fk_loan_repayments_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`loan_id`),
  CONSTRAINT `fk_loan_repayments_operation_id` FOREIGN KEY (`operation_id`) REFERENCES `financial_operations` (`operation_id`)
) ENGINE=InnoDB;

-- AML & Fraud: fraud_cases
CREATE TABLE `fraud_cases` (
  `case_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `alert_id` BIGINT UNSIGNED,
  `case_reference` VARCHAR(64),
  `case_status` VARCHAR(30),
  `opened_at` DATETIME(6),
  PRIMARY KEY (`case_id`),
  CONSTRAINT `fk_fraud_cases_alert_id` FOREIGN KEY (`alert_id`) REFERENCES `aml_alerts` (`alert_id`),
  UNIQUE KEY `uq_fraud_cases_case_reference` (`case_reference`)
) ENGINE=InnoDB;

-- AML & Fraud: transaction_monitoring_alerts
CREATE TABLE `transaction_monitoring_alerts` (
  `alert_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `transaction_id` BIGINT UNSIGNED,
  `rule_id` BIGINT UNSIGNED,
  `severity` VARCHAR(20),
  `status` VARCHAR(30),
  `triggered_at` DATETIME(6),
  PRIMARY KEY (`alert_id`),
  CONSTRAINT `fk_transaction_monitoring_alerts_transaction_id` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`),
  CONSTRAINT `fk_transaction_monitoring_alerts_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `transaction_monitoring_rules` (`rule_id`)
) ENGINE=InnoDB;

-- AML & Fraud: fraud_case_events
CREATE TABLE `fraud_case_events` (
  `event_id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `case_id` BIGINT UNSIGNED,
  `event_type` VARCHAR(30),
  `notes` TEXT,
  `created_at` DATETIME(6),
  PRIMARY KEY (`event_id`),
  CONSTRAINT `fk_fraud_case_events_case_id` FOREIGN KEY (`case_id`) REFERENCES `fraud_cases` (`case_id`)
) ENGINE=InnoDB;

CREATE TRIGGER `block_transactions_update` BEFORE UPDATE ON `transactions`
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'transactions is append-only';

CREATE TRIGGER `block_transactions_delete` BEFORE DELETE ON `transactions`
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'transactions is append-only';

CREATE TRIGGER `block_transaction_status_history_update` BEFORE UPDATE ON `transaction_status_history`
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'transaction_status_history is append-only';

CREATE TRIGGER `block_transaction_status_history_delete` BEFORE DELETE ON `transaction_status_history`
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'transaction_status_history is append-only';

CREATE TRIGGER `block_journal_headers_update` BEFORE UPDATE ON `journal_headers`
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'journal_headers is append-only';

CREATE TRIGGER `block_journal_headers_delete` BEFORE DELETE ON `journal_headers`
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'journal_headers is append-only';

CREATE TRIGGER `block_journal_lines_update` BEFORE UPDATE ON `journal_lines`
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'journal_lines is append-only';

CREATE TRIGGER `block_journal_lines_delete` BEFORE DELETE ON `journal_lines`
FOR EACH ROW SIGNAL SQLSTATE '45000'
SET MESSAGE_TEXT = 'journal_lines is append-only';

-- Seed lookup statuses (idempotent only on fresh schema; run once).
INSERT INTO transaction_statuses(status_id,status_code,description,is_terminal) VALUES
(1,'INITIATED','Request accepted',0),(2,'PENDING','Awaiting processing',0),
(3,'PROCESSING','Processing',0),(4,'SUCCESSFUL','Completed',1),
(5,'FAILED','Failed',1),(6,'REVERSED','Reversal registered',1),
(7,'CANCELLED','Cancelled',1);

-- TEST: UPDATE transactions and DELETE transactions must fail after a test row exists.
-- NEXT: atomic journal posting, balance checks, state-machine validation, privileges and test data.