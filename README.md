# Apex Digital Bank — Advanced Database Systems

**Course:** MIT 8103 — Advanced Database Systems  
**Institution:** MIVA Open University  
**Student:** Uchenna Egeolu - u.egeolu24120@miva.edu.ng 
**Academic Session:** 2026/2027  
**Project Type:** Individual Continuous Assessment Portfolio  
**Database Technologies:** MySQL 8, MongoDB 8, Docker and MySQL Workbench

---

## 1. Project Overview

Apex Digital Bank is a simulated digital banking platform developed to demonstrate the practical application of advanced database management concepts within a financial services environment.

The project addresses relational database architecture, data modelling and normalisation, query processing and optimisation, transaction management, concurrency control, NoSQL database implementation, and distributed database replication.

The implementation combines theoretical database principles with practical experiments, executable scripts, execution plans, database diagrams, and documented testing evidence.

All customer records, account information, transactions, fraud events, and other demonstration data are synthetic. The system does not process real banking transactions.

## 2. Project Objectives

The primary objectives are to:

1. Design a comprehensive relational database for a simulated digital banking environment.
2. Apply relational modelling, normalisation, referential integrity, and data protection constraints.
3. Investigate SQL query performance using indexing strategies and execution plans.
4. Demonstrate ACID transaction properties and concurrency control mechanisms.
5. Implement document-oriented data models for semi-structured banking information.
6. Configure and validate database replication across independent database instances.
7. Evaluate the implications of consistency, availability, scalability, and fault tolerance for banking systems.

## 3. Technology Stack

| Technology | Purpose |
|---|---|
| MySQL 8 | Relational database implementation, SQL optimisation, transaction management, and replication |
| MySQL Workbench | Relational modelling, EER diagrams, SQL execution, and database administration |
| MongoDB 8 | Document-oriented modelling, CRUD operations, aggregation pipelines, and indexing |
| MongoDB Shell (mongosh) | Execution of MongoDB scripts and database experiments |
| Docker and Docker Compose | Containerised primary–replica database environment |
| Git and GitHub | Source control, documentation, and submission evidence |
| SQL and JavaScript | Database schema, queries, procedures, experiments, and NoSQL scripts |

## 4. Database Architecture

### 4.1 Relational Database

The Apex Digital Bank relational architecture contains **45 tables** covering the following functional domains:

- Customer management, identification, and KYC.
- Bank accounts, account schemes, and restrictions.
- Financial operations and transaction processing.
- Double-entry general ledger and accounting records.
- Loan management and eligibility assessment.
- Anti-money laundering screening and fraud monitoring.
- Document management and banking mandates.
- Administrative controls and audit-related records.

The schema uses MySQL InnoDB, primary and foreign key relationships, integrity constraints, and appropriate data types.

Append-only protection triggers are implemented for selected financial and audit-sensitive records to restrict unauthorised modification or deletion.

The database design is supported by a master EER diagram, six modular EER diagrams, and a structured data dictionary.

### 4.2 NoSQL Database

MongoDB is used to demonstrate document-oriented storage for data that may contain variable attributes or evolve independently of the core relational schema.

The database is named `apex_digital_bank_nosql` and contains three collections:

- `fraud_events` — fraud detection events, severity levels, investigation details, and risk indicators.
- `customer_activity_logs` — customer activity records, channels, event outcomes, and associated metadata.
- `transaction_risk_profiles` — transaction risk assessments, scoring, and review decisions.

The implementation includes collection creation, synthetic data insertion, indexing, CRUD operations, aggregation pipelines, and query execution analysis.

### 4.3 Distributed Database Architecture

A containerised MySQL primary–replica architecture is implemented using Docker Compose.

The architecture consists of two independent MySQL 8 instances:

| Instance | Container | Host Port | Role |
|---|---|---|---|
| Primary | `apex-mysql-primary` | 3307 | Primary database and write operations |
| Replica | `apex-mysql-replica` | 3308 | Replicated data and read-oriented operations |

Both instances communicate over Docker's internal network.

Replication is configured using:

- Unique MySQL server identifiers.
- Binary logging.
- Row-based binary log format.
- Global Transaction Identifiers (GTIDs).
- Automatic GTID positioning.
- A dedicated replication user.
- Replica read-only and super-read-only protection.

The implementation demonstrates asynchronous data replication and consistency verification within a local environment.

**Scope clarification:** This exercise simulates distributed database deployment locally. It does not represent a production cloud deployment, multi-region replication, or an automatically managed failover cluster.

## 5. Assessment Portfolios

### Portfolio 1 — Database Design and Modelling

**Directory:** `01-database-design/`

This portfolio covers:

- Conceptual and logical database design.
- Physical MySQL relational schema implementation.
- Entity relationships and referential integrity.
- Database normalisation.
- Master and modular EER diagrams.
- Data dictionary.
- Integrity constraints and append-only protection triggers.

**Outcome:** A comprehensive relational banking database design supported by executable SQL and architectural documentation.

### Portfolio 2 — Query Processing and Optimisation

**Directory:** `02-query-optimization/`

This portfolio investigates relational query execution and optimisation.

Activities include:

- SQL query design.
- Query execution plan inspection.
- Indexing strategies.
- Comparison of query execution behaviour.
- Interpretation of database optimisation results.

**Outcome:** Practical analysis of how database access paths and indexing influence query performance.

### Portfolio 3 — Transactions and Concurrency

**Directory:** `03-transactions-concurrency/`

This portfolio examines transaction reliability and concurrent database operations.

Activities include:

- ACID transaction properties.
- Transaction commit and rollback behaviour.
- Isolation levels.
- Concurrent transaction execution.
- Locking and consistency mechanisms.
- Transaction failure and recovery considerations.

**Outcome:** Practical demonstrations of database transaction integrity and concurrency control in a financial services context.

### Portfolio 4 — NoSQL and Advanced Data Models

**Directory:** `04-nosql/`

This portfolio implements MongoDB as a complementary document-oriented database.

The implementation includes:

- Three banking-related document collections.
- Synthetic JSON document records.
- Single-field, compound, and unique indexes.
- CRUD operations.
- Investigation status updates.
- Aggregation pipelines.
- Query execution plan analysis.

The MongoDB query analysis demonstrated use of the compound index `idx_fraud_customer_date` through an `IXSCAN` execution stage.

The observed test examined one index key and one document to return one matching record.

**Outcome:** A working document database with indexed queries, aggregation analysis, and executable CRUD demonstrations.

### Portfolio 5 — Distributed and Cloud Databases

**Directory:** `05-distributed-cloud/`

This portfolio demonstrates distributed relational database concepts using two containerised MySQL instances.

The implementation includes:

- Docker Compose configuration.
- Primary and replica database provisioning.
- GTID-based replication.
- Binary logging configuration.
- Replication account and privilege configuration.
- Replication health verification.
- Primary-to-replica data synchronisation.
- Read-only protection on the replica.
- Discussion of cloud deployment, availability, and consistency.

Replication health checks confirmed that both replication threads were running, with no reported replication errors and zero seconds behind the source at the observed checkpoint.

Synthetic transaction records inserted into the primary were successfully retrieved from the replica.

Replica write protection was also demonstrated by enabling `read_only` and `super_read_only`, followed by a rejected direct insert attempt.

**Outcome:** A functioning local MySQL primary–replica environment demonstrating asynchronous replication, data synchronisation, and replica write protection.

## 6. Project Directory Structure

```text
apex-digital-bank-database/
│
├── 01-database-design/
│   └── ...
│
├── 02-query-optimization/
│   └── ...
│
├── 03-transactions-concurrency/
│   └── ...
│
├── 04-nosql/
│   ├── mongodb/
│   │   ├── 01-create-collections.js
│   │   ├── 02-seed-data.js
│   │   ├── 03-indexes.js
│   │   ├── 04-aggregations.js
│   │   └── 05-crud-operations.js
│   ├── sample-data/
│   ├── screenshots/
│   ├── analysis.md
│   └── README.md
│
├── 05-distributed-cloud/
│   ├── configuration/
│   ├── mysql/
│   │   └── compose.yml
│   ├── screenshots/
│   ├── .env.example
│   ├── analysis.md
│   └── .env                 # Local only; excluded from Git
│
├── documentation/
├── .gitignore
└── README.md
```

Each portfolio contains its respective implementation materials, analysis, and supporting evidence, as applicable.

## 7. Reproducing the Experiments

### 7.1 Prerequisites

Install the following tools:

- MySQL 8.
- MySQL Workbench.
- MongoDB Community Server 8.
- MongoDB Shell (`mongosh`).
- Docker Desktop with Docker Compose.
- Git.

### 7.2 Relational Database Setup

Execute the relational schema:

`01-database-design/schema/apex_digital_bank_schema_v1.sql`

Use a new MySQL database environment to avoid modifying existing data.

Refer to the relevant portfolio folders for additional SQL experiments and their execution order.

### 7.3 MongoDB Setup

Start the local MongoDB server and execute the scripts from the repository root.

```bash
mongosh mongodb://127.0.0.1:27017/apex_digital_bank_nosql 04-nosql/mongodb/01-create-collections.js

mongosh mongodb://127.0.0.1:27017/apex_digital_bank_nosql 04-nosql/mongodb/02-seed-data.js

mongosh mongodb://127.0.0.1:27017/apex_digital_bank_nosql 04-nosql/mongodb/03-indexes.js

mongosh mongodb://127.0.0.1:27017/apex_digital_bank_nosql 04-nosql/mongodb/04-aggregations.js

mongosh mongodb://127.0.0.1:27017/apex_digital_bank_nosql 04-nosql/mongodb/05-crud-operations.js
```

The scripts demonstrate document creation, data population, indexing, aggregation, and CRUD functionality.

### 7.4 Distributed MySQL Setup

Navigate to the distributed database portfolio:

```bash
cd 05-distributed-cloud
```

Create a local environment configuration file:

```bash
cp .env.example .env
```

Update the environment variables with local demonstration credentials.

Validate the Docker Compose configuration:

```bash
docker compose --env-file .env -f mysql/compose.yml config --quiet
```

Start the database containers:

```bash
docker compose --env-file .env -f mysql/compose.yml up -d
```

Check their status:

```bash
docker compose --env-file .env -f mysql/compose.yml ps
```

Connect to the primary database:

```bash
docker exec -it apex-mysql-primary mysql -uroot -p
```

Connect to the replica database:

```bash
docker exec -it apex-mysql-replica mysql -uroot -p
```

On the replica, verify replication health:

```sql
SHOW REPLICA STATUS\G
```

Important indicators include:

- `Replica_IO_Running: Yes`
- `Replica_SQL_Running: Yes`
- `Last_IO_Errno: 0`
- `Last_SQL_Errno: 0`

On the primary, inspect binary logging:

```sql
SHOW MASTER STATUS;
```

The primary–replica configuration and test procedures are documented in `05-distributed-cloud/analysis.md`.

**Important:** Docker Compose provisions the database instances, but replication source configuration and initialisation must also be completed as documented. Starting the containers alone does not guarantee that replication is configured.

## 8. Testing and Evidence

Each portfolio is supported by relevant implementation evidence, which may include:

- SQL execution results.
- MySQL Workbench EER diagrams.
- Database schema and data dictionary.
- Query execution plans.
- Transaction and concurrency experiments.
- MongoDB CRUD and aggregation outputs.
- MongoDB index execution statistics.
- Docker Compose configuration.
- MySQL replication health checks.
- Primary–replica data verification.
- Replica write-protection tests.

Screenshots are retained in their respective portfolio directories.

Performance measurements represent observations from the local test environment and should not be interpreted as production benchmarks.

## 9. Technical Considerations and Limitations

The implementation is intended for educational demonstration rather than production banking operations.

Important limitations include:

- Synthetic datasets may not reproduce real-world banking workloads.
- Query performance depends on data volume, indexes, hardware, and database configuration.
- Local concurrency tests do not fully reproduce production transaction volumes.
- MongoDB is demonstrated as a complementary data model rather than a replacement for the core relational ledger.
- Asynchronous replication may introduce temporary differences between the primary and replica.
- Replica consistency must be considered when supporting balance enquiries or other time-sensitive banking operations.
- Automatic failover, cross-region deployment, and production disaster recovery are outside the demonstrated implementation scope.
- Docker-based replication does not independently provide a complete high-availability architecture.

A production implementation would require additional security controls, encryption, monitoring, backup and recovery processes, operational governance, and formal resilience testing.

## 10. Security and Configuration Management

Database passwords and environment-specific credentials are maintained in local environment configuration files.

The `.env` file is excluded from Git version control, while `.env.example` documents the required configuration variables without exposing credentials.

The project uses synthetic information and is not connected to live banking systems.

Credentials used for local demonstrations must not be reused in production environments.

## 11. Academic Integrity and AI Assistance

This repository represents an individual academic project developed for MIT 8103 — Advanced Database Systems at MIVA Open University.

AI-assisted tools were used to support planning, technical explanations, implementation guidance, troubleshooting, and documentation drafting.

The database experiments were executed in local development environments, and the reported results are supported by captured execution evidence.

All implementation outcomes and screenshots should be independently verified before academic submission.

AI assistance will be disclosed in accordance with the institution's applicable academic integrity requirements.

## 12. Conclusion

The Apex Digital Bank project demonstrates the practical application of advanced database systems concepts within a simulated financial services environment.

Across five portfolios, the project integrates relational database modelling, SQL optimisation, transaction and concurrency control, document-oriented data management, and distributed database replication.

The implementation illustrates the relationship between data integrity, query efficiency, transactional consistency, scalability, and availability in banking database architecture.

The project provides a reproducible educational foundation for evaluating database design decisions and their operational implications.

---

**Repository:** https://github.com/UchennaEgeolu/apex-digital-bank-database  
**Course:** MIT 8103 — Advanced Database Systems  
**Institution:** MIVA Open University  
**Academic Session:** 2026/2027