-- MySQL dump 10.13  Distrib 8.0.44, for macos15 (x86_64)
--
-- Host: localhost    Database: apex_digital_bank
-- ------------------------------------------------------
-- Server version	8.0.44

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `account_balance_snapshots`
--

DROP TABLE IF EXISTS `account_balance_snapshots`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_balance_snapshots` (
  `snapshot_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint unsigned DEFAULT NULL,
  `ledger_balance` decimal(19,4) DEFAULT NULL,
  `available_balance` decimal(19,4) DEFAULT NULL,
  `snapshot_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`snapshot_id`),
  KEY `fk_account_balance_snapshots_account_id` (`account_id`),
  CONSTRAINT `fk_account_balance_snapshots_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_holders`
--

DROP TABLE IF EXISTS `account_holders`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_holders` (
  `holder_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint unsigned DEFAULT NULL,
  `customer_id` bigint unsigned DEFAULT NULL,
  `ownership_role` varchar(40) DEFAULT NULL,
  `is_primary` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`holder_id`),
  KEY `fk_account_holders_account_id` (`account_id`),
  KEY `fk_account_holders_customer_id` (`customer_id`),
  CONSTRAINT `fk_account_holders_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_account_holders_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_mandates`
--

DROP TABLE IF EXISTS `account_mandates`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_mandates` (
  `mandate_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint unsigned DEFAULT NULL,
  `document_id` bigint unsigned DEFAULT NULL,
  `mandate_type` varchar(30) DEFAULT NULL,
  `signing_rule` varchar(80) DEFAULT NULL,
  `approval_status` varchar(30) DEFAULT NULL,
  `effective_from` datetime(6) DEFAULT NULL,
  `effective_to` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`mandate_id`),
  KEY `fk_account_mandates_account_id` (`account_id`),
  KEY `fk_account_mandates_document_id` (`document_id`),
  CONSTRAINT `fk_account_mandates_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_account_mandates_document_id` FOREIGN KEY (`document_id`) REFERENCES `customer_documents` (`document_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_restrictions`
--

DROP TABLE IF EXISTS `account_restrictions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_restrictions` (
  `restriction_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint unsigned DEFAULT NULL,
  `restriction_type` varchar(30) DEFAULT NULL,
  `reason_code` varchar(60) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `effective_from` datetime(6) DEFAULT NULL,
  `effective_to` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`restriction_id`),
  KEY `fk_account_restrictions_account_id` (`account_id`),
  CONSTRAINT `fk_account_restrictions_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `chk_restriction_dates` CHECK (((`effective_to` is null) or (`effective_to` >= `effective_from`)))
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_schemes`
--

DROP TABLE IF EXISTS `account_schemes`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_schemes` (
  `scheme_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_type_id` bigint unsigned DEFAULT NULL,
  `scheme_code` varchar(20) DEFAULT NULL,
  `scheme_name` varchar(100) DEFAULT NULL,
  `currency` char(3) DEFAULT NULL,
  `minimum_balance` decimal(19,4) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`scheme_id`),
  UNIQUE KEY `uq_account_schemes_scheme_code` (`scheme_code`),
  KEY `fk_account_schemes_account_type_id` (`account_type_id`),
  CONSTRAINT `fk_account_schemes_account_type_id` FOREIGN KEY (`account_type_id`) REFERENCES `account_types` (`account_type_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_status_history`
--

DROP TABLE IF EXISTS `account_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_status_history` (
  `history_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `account_id` bigint unsigned DEFAULT NULL,
  `previous_status` varchar(30) DEFAULT NULL,
  `new_status` varchar(30) DEFAULT NULL,
  `changed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`history_id`),
  KEY `fk_account_status_history_account_id` (`account_id`),
  CONSTRAINT `fk_account_status_history_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=136 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `account_types`
--

DROP TABLE IF EXISTS `account_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `account_types` (
  `account_type_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `type_code` varchar(20) DEFAULT NULL,
  `type_name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`account_type_id`),
  UNIQUE KEY `uq_account_types_type_code` (`type_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `aml_alerts`
--

DROP TABLE IF EXISTS `aml_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aml_alerts` (
  `alert_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `match_id` bigint unsigned DEFAULT NULL,
  `severity` varchar(20) DEFAULT NULL,
  `alert_status` varchar(30) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`alert_id`),
  KEY `fk_aml_alerts_match_id` (`match_id`),
  CONSTRAINT `fk_aml_alerts_match_id` FOREIGN KEY (`match_id`) REFERENCES `screening_matches` (`match_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `bank_accounts`
--

DROP TABLE IF EXISTS `bank_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `bank_accounts` (
  `account_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `scheme_id` bigint unsigned DEFAULT NULL,
  `account_number` varchar(20) DEFAULT NULL,
  `account_name` varchar(160) DEFAULT NULL,
  `currency` char(3) DEFAULT NULL,
  `account_status` varchar(30) DEFAULT NULL,
  `debit_status` varchar(30) DEFAULT NULL,
  `credit_status` varchar(30) DEFAULT NULL,
  `available_balance` decimal(19,4) DEFAULT NULL,
  `ledger_balance` decimal(19,4) DEFAULT NULL,
  `opened_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`account_id`),
  UNIQUE KEY `uq_bank_accounts_account_number` (`account_number`),
  KEY `fk_bank_accounts_customer_id` (`customer_id`),
  KEY `fk_bank_accounts_scheme_id` (`scheme_id`),
  CONSTRAINT `fk_bank_accounts_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_bank_accounts_scheme_id` FOREIGN KEY (`scheme_id`) REFERENCES `account_schemes` (`scheme_id`)
) ENGINE=InnoDB AUTO_INCREMENT=169 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_credit_profiles`
--

DROP TABLE IF EXISTS `customer_credit_profiles`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_credit_profiles` (
  `profile_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `bureau_reference` varchar(80) DEFAULT NULL,
  `credit_score` int DEFAULT NULL,
  `total_outstanding_debt` decimal(19,4) DEFAULT NULL,
  `assessed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`profile_id`),
  KEY `fk_customer_credit_profiles_customer_id` (`customer_id`),
  CONSTRAINT `fk_customer_credit_profiles_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_documents`
--

DROP TABLE IF EXISTS `customer_documents`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_documents` (
  `document_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `account_id` bigint unsigned DEFAULT NULL,
  `document_type_id` bigint unsigned DEFAULT NULL,
  `document_name` varchar(255) DEFAULT NULL,
  `storage_path` varchar(500) DEFAULT NULL,
  `checksum` varchar(128) DEFAULT NULL,
  `verification_status` varchar(30) DEFAULT NULL,
  `uploaded_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`document_id`),
  KEY `fk_customer_documents_customer_id` (`customer_id`),
  KEY `fk_customer_documents_account_id` (`account_id`),
  KEY `fk_customer_documents_document_type_id` (`document_type_id`),
  CONSTRAINT `fk_customer_documents_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_customer_documents_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_customer_documents_document_type_id` FOREIGN KEY (`document_type_id`) REFERENCES `document_types` (`document_type_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_identity_links`
--

DROP TABLE IF EXISTS `customer_identity_links`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_identity_links` (
  `link_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `bvn_verification_id` bigint unsigned DEFAULT NULL,
  `nin_verification_id` bigint unsigned DEFAULT NULL,
  `linking_status` varchar(30) DEFAULT NULL,
  `linked_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`link_id`),
  KEY `fk_customer_identity_links_customer_id` (`customer_id`),
  KEY `fk_customer_identity_links_bvn_verification_id` (`bvn_verification_id`),
  KEY `fk_customer_identity_links_nin_verification_id` (`nin_verification_id`),
  CONSTRAINT `fk_customer_identity_links_bvn_verification_id` FOREIGN KEY (`bvn_verification_id`) REFERENCES `customer_identity_verifications` (`verification_id`),
  CONSTRAINT `fk_customer_identity_links_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_customer_identity_links_nin_verification_id` FOREIGN KEY (`nin_verification_id`) REFERENCES `customer_identity_verifications` (`verification_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_identity_verifications`
--

DROP TABLE IF EXISTS `customer_identity_verifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_identity_verifications` (
  `verification_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `identity_type` varchar(20) DEFAULT NULL,
  `identifier_token` varchar(128) DEFAULT NULL,
  `verification_status` varchar(30) DEFAULT NULL,
  `provider_reference` varchar(80) DEFAULT NULL,
  `verified_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`verification_id`),
  KEY `fk_customer_identity_verifications_customer_id` (`customer_id`),
  CONSTRAINT `fk_customer_identity_verifications_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_relationships`
--

DROP TABLE IF EXISTS `customer_relationships`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_relationships` (
  `relationship_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `related_customer_id` bigint unsigned DEFAULT NULL,
  `relationship_type` varchar(40) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`relationship_id`),
  KEY `fk_customer_relationships_customer_id` (`customer_id`),
  KEY `fk_customer_relationships_related_customer_id` (`related_customer_id`),
  CONSTRAINT `fk_customer_relationships_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_customer_relationships_related_customer_id` FOREIGN KEY (`related_customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_risk_assessments`
--

DROP TABLE IF EXISTS `customer_risk_assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_risk_assessments` (
  `risk_assessment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `risk_type` varchar(30) DEFAULT NULL,
  `risk_rating` varchar(20) DEFAULT NULL,
  `assessment_version` varchar(30) DEFAULT NULL,
  `assessed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`risk_assessment_id`),
  KEY `fk_customer_risk_assessments_customer_id` (`customer_id`),
  CONSTRAINT `fk_customer_risk_assessments_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=201 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_screenings`
--

DROP TABLE IF EXISTS `customer_screenings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_screenings` (
  `screening_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `screening_type` varchar(30) DEFAULT NULL,
  `screening_status` varchar(30) DEFAULT NULL,
  `screened_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`screening_id`),
  KEY `fk_customer_screenings_customer_id` (`customer_id`),
  CONSTRAINT `fk_customer_screenings_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customer_status_history`
--

DROP TABLE IF EXISTS `customer_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customer_status_history` (
  `history_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `old_status` varchar(30) DEFAULT NULL,
  `new_status` varchar(30) DEFAULT NULL,
  `reason` varchar(255) DEFAULT NULL,
  `changed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`history_id`),
  KEY `fk_customer_status_history_customer_id` (`customer_id`),
  CONSTRAINT `fk_customer_status_history_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `customers`
--

DROP TABLE IF EXISTS `customers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `customers` (
  `customer_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_number` varchar(30) DEFAULT NULL,
  `customer_type` varchar(20) DEFAULT NULL,
  `title` varchar(20) DEFAULT NULL,
  `first_name` varchar(100) DEFAULT NULL,
  `middle_name` varchar(100) DEFAULT NULL,
  `last_name` varchar(100) DEFAULT NULL,
  `date_of_birth` date DEFAULT NULL,
  `gender` varchar(30) DEFAULT NULL,
  `marital_status` varchar(30) DEFAULT NULL,
  `email` varchar(150) DEFAULT NULL,
  `phone_number` varchar(25) DEFAULT NULL,
  `alternate_phone_number` varchar(25) DEFAULT NULL,
  `residential_address` varchar(255) DEFAULT NULL,
  `city` varchar(100) DEFAULT NULL,
  `state` varchar(100) DEFAULT NULL,
  `country` char(2) DEFAULT NULL,
  `postal_code` varchar(20) DEFAULT NULL,
  `nationality` char(2) DEFAULT NULL,
  `state_of_origin` varchar(100) DEFAULT NULL,
  `occupation` varchar(100) DEFAULT NULL,
  `employment_status` varchar(40) DEFAULT NULL,
  `employer_name` varchar(150) DEFAULT NULL,
  `annual_income` decimal(19,4) DEFAULT NULL,
  `customer_status` varchar(30) DEFAULT NULL,
  `customer_segment` varchar(40) DEFAULT NULL,
  `relationship_manager_id` bigint unsigned DEFAULT NULL,
  `onboarding_channel` varchar(30) DEFAULT NULL,
  `onboarding_date` datetime(6) DEFAULT NULL,
  `bvn_verification_status` varchar(30) DEFAULT NULL,
  `nin_verification_status` varchar(30) DEFAULT NULL,
  `nin_bvn_linking_status` varchar(30) DEFAULT NULL,
  `kyc_level` varchar(20) DEFAULT NULL,
  `kyc_status` varchar(30) DEFAULT NULL,
  `kyc_last_reviewed_at` datetime(6) DEFAULT NULL,
  `credit_risk_rating` varchar(20) DEFAULT NULL,
  `last_credit_assessment_at` datetime(6) DEFAULT NULL,
  `aml_risk_rating` varchar(20) DEFAULT NULL,
  `is_pep` tinyint(1) DEFAULT NULL,
  `aml_screening_status` varchar(30) DEFAULT NULL,
  `last_aml_screened_at` datetime(6) DEFAULT NULL,
  `is_blacklisted` tinyint(1) DEFAULT NULL,
  `is_deceased` tinyint(1) DEFAULT NULL,
  `is_dormant` tinyint(1) DEFAULT NULL,
  `restriction_status` varchar(30) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  `updated_at` datetime(6) DEFAULT NULL,
  `created_by` bigint unsigned DEFAULT NULL,
  `updated_by` bigint unsigned DEFAULT NULL,
  PRIMARY KEY (`customer_id`),
  UNIQUE KEY `uq_customers_customer_number` (`customer_number`),
  KEY `fk_customers_relationship_manager_id` (`relationship_manager_id`),
  KEY `fk_customers_created_by` (`created_by`),
  KEY `fk_customers_updated_by` (`updated_by`),
  CONSTRAINT `fk_customers_created_by` FOREIGN KEY (`created_by`) REFERENCES `system_users` (`user_id`),
  CONSTRAINT `fk_customers_relationship_manager_id` FOREIGN KEY (`relationship_manager_id`) REFERENCES `system_users` (`user_id`),
  CONSTRAINT `fk_customers_updated_by` FOREIGN KEY (`updated_by`) REFERENCES `system_users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=101 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `document_types`
--

DROP TABLE IF EXISTS `document_types`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `document_types` (
  `document_type_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `type_code` varchar(30) DEFAULT NULL,
  `type_name` varchar(100) DEFAULT NULL,
  `requires_verification` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`document_type_id`),
  UNIQUE KEY `uq_document_types_type_code` (`type_code`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `financial_operations`
--

DROP TABLE IF EXISTS `financial_operations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `financial_operations` (
  `operation_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `operation_reference` varchar(64) DEFAULT NULL,
  `operation_type` varchar(30) DEFAULT NULL,
  `channel_id` bigint unsigned DEFAULT NULL,
  `source_account_id` bigint unsigned DEFAULT NULL,
  `destination_account_id` bigint unsigned DEFAULT NULL,
  `total_amount` decimal(19,4) DEFAULT NULL,
  `currency` char(3) DEFAULT NULL,
  `idempotency_key` varchar(100) DEFAULT NULL,
  `initiated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`operation_id`),
  UNIQUE KEY `uq_financial_operations_operation_reference` (`operation_reference`),
  UNIQUE KEY `uq_financial_operations_idempotency_key` (`idempotency_key`),
  KEY `fk_financial_operations_channel_id` (`channel_id`),
  KEY `fk_financial_operations_source_account_id` (`source_account_id`),
  KEY `fk_financial_operations_destination_account_id` (`destination_account_id`),
  CONSTRAINT `fk_financial_operations_channel_id` FOREIGN KEY (`channel_id`) REFERENCES `transaction_channels` (`channel_id`),
  CONSTRAINT `fk_financial_operations_destination_account_id` FOREIGN KEY (`destination_account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_financial_operations_source_account_id` FOREIGN KEY (`source_account_id`) REFERENCES `bank_accounts` (`account_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fraud_case_events`
--

DROP TABLE IF EXISTS `fraud_case_events`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fraud_case_events` (
  `event_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `case_id` bigint unsigned DEFAULT NULL,
  `event_type` varchar(30) DEFAULT NULL,
  `notes` text,
  `created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`event_id`),
  KEY `fk_fraud_case_events_case_id` (`case_id`),
  CONSTRAINT `fk_fraud_case_events_case_id` FOREIGN KEY (`case_id`) REFERENCES `fraud_cases` (`case_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `fraud_cases`
--

DROP TABLE IF EXISTS `fraud_cases`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `fraud_cases` (
  `case_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `alert_id` bigint unsigned DEFAULT NULL,
  `case_reference` varchar(64) DEFAULT NULL,
  `case_status` varchar(30) DEFAULT NULL,
  `opened_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`case_id`),
  UNIQUE KEY `uq_fraud_cases_case_reference` (`case_reference`),
  KEY `fk_fraud_cases_alert_id` (`alert_id`),
  CONSTRAINT `fk_fraud_cases_alert_id` FOREIGN KEY (`alert_id`) REFERENCES `aml_alerts` (`alert_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `gl_accounts`
--

DROP TABLE IF EXISTS `gl_accounts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `gl_accounts` (
  `gl_account_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `gl_code` varchar(30) DEFAULT NULL,
  `gl_name` varchar(100) DEFAULT NULL,
  `account_class` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`gl_account_id`),
  UNIQUE KEY `uq_gl_accounts_gl_code` (`gl_code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journal_headers`
--

DROP TABLE IF EXISTS `journal_headers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_headers` (
  `journal_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `operation_id` bigint unsigned DEFAULT NULL,
  `journal_reference` varchar(64) DEFAULT NULL,
  `posted_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`journal_id`),
  UNIQUE KEY `uq_journal_headers_journal_reference` (`journal_reference`),
  KEY `fk_journal_headers_operation_id` (`operation_id`),
  CONSTRAINT `fk_journal_headers_operation_id` FOREIGN KEY (`operation_id`) REFERENCES `financial_operations` (`operation_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `journal_lines`
--

DROP TABLE IF EXISTS `journal_lines`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `journal_lines` (
  `line_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `journal_id` bigint unsigned DEFAULT NULL,
  `gl_account_id` bigint unsigned DEFAULT NULL,
  `account_id` bigint unsigned DEFAULT NULL,
  `entry_type` varchar(6) DEFAULT NULL,
  `amount` decimal(19,4) DEFAULT NULL,
  `currency` char(3) DEFAULT NULL,
  PRIMARY KEY (`line_id`),
  KEY `fk_journal_lines_journal_id` (`journal_id`),
  KEY `fk_journal_lines_gl_account_id` (`gl_account_id`),
  KEY `fk_journal_lines_account_id` (`account_id`),
  CONSTRAINT `fk_journal_lines_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_journal_lines_gl_account_id` FOREIGN KEY (`gl_account_id`) REFERENCES `gl_accounts` (`gl_account_id`),
  CONSTRAINT `fk_journal_lines_journal_id` FOREIGN KEY (`journal_id`) REFERENCES `journal_headers` (`journal_id`),
  CONSTRAINT `chk_journal_entry_type` CHECK ((`entry_type` in (_utf8mb4'DEBIT',_utf8mb4'CREDIT'))),
  CONSTRAINT `chk_journal_positive` CHECK ((`amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loan_applications`
--

DROP TABLE IF EXISTS `loan_applications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_applications` (
  `application_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `product_id` bigint unsigned DEFAULT NULL,
  `assessment_id` bigint unsigned DEFAULT NULL,
  `requested_amount` decimal(19,4) DEFAULT NULL,
  `application_status` varchar(30) DEFAULT NULL,
  `applied_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`application_id`),
  KEY `fk_loan_applications_customer_id` (`customer_id`),
  KEY `fk_loan_applications_product_id` (`product_id`),
  KEY `fk_loan_applications_assessment_id` (`assessment_id`),
  CONSTRAINT `fk_loan_applications_assessment_id` FOREIGN KEY (`assessment_id`) REFERENCES `loan_eligibility_assessments` (`assessment_id`),
  CONSTRAINT `fk_loan_applications_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_loan_applications_product_id` FOREIGN KEY (`product_id`) REFERENCES `loan_products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loan_eligibility_assessments`
--

DROP TABLE IF EXISTS `loan_eligibility_assessments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_eligibility_assessments` (
  `assessment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` bigint unsigned DEFAULT NULL,
  `product_id` bigint unsigned DEFAULT NULL,
  `requested_amount` decimal(19,4) DEFAULT NULL,
  `monthly_income` decimal(19,4) DEFAULT NULL,
  `debt_to_income_ratio` decimal(7,4) DEFAULT NULL,
  `credit_score` int DEFAULT NULL,
  `eligibility_status` varchar(30) DEFAULT NULL,
  `assessed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`assessment_id`),
  KEY `fk_loan_eligibility_assessments_customer_id` (`customer_id`),
  KEY `fk_loan_eligibility_assessments_product_id` (`product_id`),
  CONSTRAINT `fk_loan_eligibility_assessments_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_loan_eligibility_assessments_product_id` FOREIGN KEY (`product_id`) REFERENCES `loan_products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loan_eligibility_rule_results`
--

DROP TABLE IF EXISTS `loan_eligibility_rule_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_eligibility_rule_results` (
  `result_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `assessment_id` bigint unsigned DEFAULT NULL,
  `rule_id` bigint unsigned DEFAULT NULL,
  `passed` tinyint(1) DEFAULT NULL,
  `reason_code` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`result_id`),
  KEY `fk_loan_eligibility_rule_results_assessment_id` (`assessment_id`),
  KEY `fk_loan_eligibility_rule_results_rule_id` (`rule_id`),
  CONSTRAINT `fk_loan_eligibility_rule_results_assessment_id` FOREIGN KEY (`assessment_id`) REFERENCES `loan_eligibility_assessments` (`assessment_id`),
  CONSTRAINT `fk_loan_eligibility_rule_results_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `loan_eligibility_rules` (`rule_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loan_eligibility_rules`
--

DROP TABLE IF EXISTS `loan_eligibility_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_eligibility_rules` (
  `rule_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_id` bigint unsigned DEFAULT NULL,
  `rule_code` varchar(40) DEFAULT NULL,
  `rule_version` varchar(30) DEFAULT NULL,
  `operator` varchar(10) DEFAULT NULL,
  `threshold_value` decimal(19,4) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`rule_id`),
  KEY `fk_loan_eligibility_rules_product_id` (`product_id`),
  CONSTRAINT `fk_loan_eligibility_rules_product_id` FOREIGN KEY (`product_id`) REFERENCES `loan_products` (`product_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loan_products`
--

DROP TABLE IF EXISTS `loan_products`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_products` (
  `product_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `product_code` varchar(30) DEFAULT NULL,
  `product_name` varchar(100) DEFAULT NULL,
  `interest_rate` decimal(9,4) DEFAULT NULL,
  `maximum_tenor` int DEFAULT NULL,
  `maximum_amount` decimal(19,4) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`product_id`),
  UNIQUE KEY `uq_loan_products_product_code` (`product_code`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loan_repayment_schedules`
--

DROP TABLE IF EXISTS `loan_repayment_schedules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_repayment_schedules` (
  `schedule_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `loan_id` bigint unsigned DEFAULT NULL,
  `due_date` date DEFAULT NULL,
  `principal_due` decimal(19,4) DEFAULT NULL,
  `interest_due` decimal(19,4) DEFAULT NULL,
  `payment_status` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`schedule_id`),
  KEY `fk_loan_repayment_schedules_loan_id` (`loan_id`),
  CONSTRAINT `fk_loan_repayment_schedules_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`loan_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loan_repayments`
--

DROP TABLE IF EXISTS `loan_repayments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loan_repayments` (
  `repayment_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `loan_id` bigint unsigned DEFAULT NULL,
  `operation_id` bigint unsigned DEFAULT NULL,
  `amount_paid` decimal(19,4) DEFAULT NULL,
  `paid_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`repayment_id`),
  KEY `fk_loan_repayments_loan_id` (`loan_id`),
  KEY `fk_loan_repayments_operation_id` (`operation_id`),
  CONSTRAINT `fk_loan_repayments_loan_id` FOREIGN KEY (`loan_id`) REFERENCES `loans` (`loan_id`),
  CONSTRAINT `fk_loan_repayments_operation_id` FOREIGN KEY (`operation_id`) REFERENCES `financial_operations` (`operation_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `loans`
--

DROP TABLE IF EXISTS `loans`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loans` (
  `loan_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `application_id` bigint unsigned DEFAULT NULL,
  `customer_id` bigint unsigned DEFAULT NULL,
  `account_id` bigint unsigned DEFAULT NULL,
  `principal_amount` decimal(19,4) DEFAULT NULL,
  `outstanding_balance` decimal(19,4) DEFAULT NULL,
  `interest_rate` decimal(9,4) DEFAULT NULL,
  `loan_status` varchar(30) DEFAULT NULL,
  `disbursed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`loan_id`),
  KEY `fk_loans_application_id` (`application_id`),
  KEY `fk_loans_customer_id` (`customer_id`),
  KEY `fk_loans_account_id` (`account_id`),
  CONSTRAINT `fk_loans_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_loans_application_id` FOREIGN KEY (`application_id`) REFERENCES `loan_applications` (`application_id`),
  CONSTRAINT `fk_loans_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `mandate_signatories`
--

DROP TABLE IF EXISTS `mandate_signatories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `mandate_signatories` (
  `signatory_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `mandate_id` bigint unsigned DEFAULT NULL,
  `customer_id` bigint unsigned DEFAULT NULL,
  `signing_role` varchar(40) DEFAULT NULL,
  `signing_priority` int DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`signatory_id`),
  KEY `fk_mandate_signatories_mandate_id` (`mandate_id`),
  KEY `fk_mandate_signatories_customer_id` (`customer_id`),
  CONSTRAINT `fk_mandate_signatories_customer_id` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`),
  CONSTRAINT `fk_mandate_signatories_mandate_id` FOREIGN KEY (`mandate_id`) REFERENCES `account_mandates` (`mandate_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `screening_matches`
--

DROP TABLE IF EXISTS `screening_matches`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `screening_matches` (
  `match_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `screening_id` bigint unsigned DEFAULT NULL,
  `entry_id` bigint unsigned DEFAULT NULL,
  `match_score` decimal(6,3) DEFAULT NULL,
  `review_status` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`match_id`),
  KEY `fk_screening_matches_screening_id` (`screening_id`),
  KEY `fk_screening_matches_entry_id` (`entry_id`),
  CONSTRAINT `fk_screening_matches_entry_id` FOREIGN KEY (`entry_id`) REFERENCES `watchlist_entries` (`entry_id`),
  CONSTRAINT `fk_screening_matches_screening_id` FOREIGN KEY (`screening_id`) REFERENCES `customer_screenings` (`screening_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `system_users`
--

DROP TABLE IF EXISTS `system_users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `system_users` (
  `user_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `username` varchar(80) DEFAULT NULL,
  `role` varchar(40) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `uq_system_users_username` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_channels`
--

DROP TABLE IF EXISTS `transaction_channels`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_channels` (
  `channel_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `channel_code` varchar(30) DEFAULT NULL,
  `channel_name` varchar(80) DEFAULT NULL,
  PRIMARY KEY (`channel_id`),
  UNIQUE KEY `uq_transaction_channels_channel_code` (`channel_code`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_monitoring_alerts`
--

DROP TABLE IF EXISTS `transaction_monitoring_alerts`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_monitoring_alerts` (
  `alert_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint unsigned DEFAULT NULL,
  `rule_id` bigint unsigned DEFAULT NULL,
  `severity` varchar(20) DEFAULT NULL,
  `status` varchar(30) DEFAULT NULL,
  `triggered_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`alert_id`),
  KEY `fk_transaction_monitoring_alerts_transaction_id` (`transaction_id`),
  KEY `fk_transaction_monitoring_alerts_rule_id` (`rule_id`),
  CONSTRAINT `fk_transaction_monitoring_alerts_rule_id` FOREIGN KEY (`rule_id`) REFERENCES `transaction_monitoring_rules` (`rule_id`),
  CONSTRAINT `fk_transaction_monitoring_alerts_transaction_id` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_monitoring_rules`
--

DROP TABLE IF EXISTS `transaction_monitoring_rules`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_monitoring_rules` (
  `rule_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `rule_code` varchar(30) DEFAULT NULL,
  `rule_name` varchar(100) DEFAULT NULL,
  `is_active` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`rule_id`),
  UNIQUE KEY `uq_transaction_monitoring_rules_rule_code` (`rule_code`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_status_history`
--

DROP TABLE IF EXISTS `transaction_status_history`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_status_history` (
  `history_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `transaction_id` bigint unsigned DEFAULT NULL,
  `status_id` bigint unsigned DEFAULT NULL,
  `reason_code` varchar(50) DEFAULT NULL,
  `changed_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`history_id`),
  KEY `fk_transaction_status_history_transaction_id` (`transaction_id`),
  KEY `fk_transaction_status_history_status_id` (`status_id`),
  CONSTRAINT `fk_transaction_status_history_status_id` FOREIGN KEY (`status_id`) REFERENCES `transaction_statuses` (`status_id`),
  CONSTRAINT `fk_transaction_status_history_transaction_id` FOREIGN KEY (`transaction_id`) REFERENCES `transactions` (`transaction_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transaction_statuses`
--

DROP TABLE IF EXISTS `transaction_statuses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transaction_statuses` (
  `status_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `status_code` varchar(30) DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `is_terminal` tinyint(1) DEFAULT NULL,
  PRIMARY KEY (`status_id`),
  UNIQUE KEY `uq_transaction_statuses_status_code` (`status_code`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `transactions`
--

DROP TABLE IF EXISTS `transactions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `transactions` (
  `transaction_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `transaction_reference` varchar(64) DEFAULT NULL,
  `operation_id` bigint unsigned DEFAULT NULL,
  `account_id` bigint unsigned DEFAULT NULL,
  `status_id` bigint unsigned DEFAULT NULL,
  `direction` varchar(10) DEFAULT NULL,
  `transaction_type` varchar(30) DEFAULT NULL,
  `amount` decimal(19,4) DEFAULT NULL,
  `currency` char(3) DEFAULT NULL,
  `narration` varchar(500) DEFAULT NULL,
  `external_reference` varchar(100) DEFAULT NULL,
  `reversal_of_transaction_id` bigint unsigned DEFAULT NULL,
  `transaction_date` datetime(6) DEFAULT NULL,
  `created_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`transaction_id`),
  UNIQUE KEY `uq_transactions_transaction_reference` (`transaction_reference`),
  KEY `fk_transactions_operation_id` (`operation_id`),
  KEY `fk_transactions_status_id` (`status_id`),
  KEY `fk_transactions_reversal_of_transaction_id` (`reversal_of_transaction_id`),
  KEY `idx_transactions_account_date` (`account_id`,`transaction_date`),
  CONSTRAINT `fk_transactions_account_id` FOREIGN KEY (`account_id`) REFERENCES `bank_accounts` (`account_id`),
  CONSTRAINT `fk_transactions_operation_id` FOREIGN KEY (`operation_id`) REFERENCES `financial_operations` (`operation_id`),
  CONSTRAINT `fk_transactions_reversal_of_transaction_id` FOREIGN KEY (`reversal_of_transaction_id`) REFERENCES `transactions` (`transaction_id`),
  CONSTRAINT `fk_transactions_status_id` FOREIGN KEY (`status_id`) REFERENCES `transaction_statuses` (`status_id`),
  CONSTRAINT `chk_transactions_direction` CHECK ((`direction` in (_utf8mb4'INFLOW',_utf8mb4'OUTFLOW'))),
  CONSTRAINT `chk_transactions_positive` CHECK ((`amount` > 0))
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `watchlist_entries`
--

DROP TABLE IF EXISTS `watchlist_entries`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `watchlist_entries` (
  `entry_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `source_id` bigint unsigned DEFAULT NULL,
  `entity_name` varchar(200) DEFAULT NULL,
  `entity_type` varchar(30) DEFAULT NULL,
  `risk_category` varchar(30) DEFAULT NULL,
  `listing_status` varchar(30) DEFAULT NULL,
  PRIMARY KEY (`entry_id`),
  KEY `fk_watchlist_entries_source_id` (`source_id`),
  CONSTRAINT `fk_watchlist_entries_source_id` FOREIGN KEY (`source_id`) REFERENCES `watchlist_sources` (`source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `watchlist_identifiers`
--

DROP TABLE IF EXISTS `watchlist_identifiers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `watchlist_identifiers` (
  `identifier_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `entry_id` bigint unsigned DEFAULT NULL,
  `identifier_type` varchar(30) DEFAULT NULL,
  `identifier_token` varchar(128) DEFAULT NULL,
  PRIMARY KEY (`identifier_id`),
  KEY `fk_watchlist_identifiers_entry_id` (`entry_id`),
  CONSTRAINT `fk_watchlist_identifiers_entry_id` FOREIGN KEY (`entry_id`) REFERENCES `watchlist_entries` (`entry_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `watchlist_sources`
--

DROP TABLE IF EXISTS `watchlist_sources`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `watchlist_sources` (
  `source_id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `source_name` varchar(100) DEFAULT NULL,
  `source_type` varchar(40) DEFAULT NULL,
  `source_url` varchar(255) DEFAULT NULL,
  `last_updated_at` datetime(6) DEFAULT NULL,
  PRIMARY KEY (`source_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-11-11 19:13:09
