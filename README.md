# Apex Digital Bank — Advanced Database Systems

**Course:** MIT 8103 — Advanced Database Systems  
**Institution:** MIVA Open University  
**Academic Session:** 2026/2027

## Project Overview

Apex Digital Bank is a simulated digital banking platform designed to demonstrate advanced database design, query optimisation, transaction management, concurrency control, NoSQL modelling, and distributed database concepts.

The relational database is implemented using MySQL 8 and modelled with MySQL Workbench.

## Database Architecture

The initial architecture consists of 45 relational tables covering:

- Customer management and KYC
- Account management, schemes and restrictions
- Financial operations and immutable transactions
- Double-entry general ledger
- Loan management and eligibility assessment
- AML screening and fraud monitoring
- Document and mandate management
- Administrative controls

All demonstration data is synthetic.

## Assessment Portfolios

1. **Database Design and Modelling:** Relational schema, EER diagrams, data dictionary and normalisation.
2. **Query Processing and Optimisation:** SQL queries, indexing and execution plan analysis.
3. **Transactions and Concurrency:** ACID properties, transaction isolation, locking and rollback demonstrations.
4. **NoSQL and Advanced Data Models:** Document database implementation.
5. **Distributed and Cloud Databases:** Replication, distribution and consistency exercises.

## Current Progress

- [x] Initial relational schema
- [x] Database creation in MySQL Workbench
- [x] Master and module-specific EER diagrams
- [x] Data dictionary
- [x] Initial append-only protection triggers
- [ ] Synthetic customer and account records
- [ ] Atomic financial posting procedures
- [ ] Query optimisation experiments
- [ ] Concurrency demonstrations
- [ ] NoSQL implementation
- [ ] Distributed database exercise

## Reproducing the Database

Execute `01-database-design/schema/apex_digital_bank_schema_v1.sql` on a compatible MySQL 8 server using a new database environment.

The schema is an educational baseline. Full accounting posting controls, transaction state validation and concurrency tests are planned for later stages.

## Academic Integrity

This is an individual academic project. AI-assisted planning and drafting will be disclosed as required by the institution. All implementation results, screenshots and testing evidence must be independently verified.