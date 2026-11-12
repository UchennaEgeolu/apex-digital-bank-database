# Portfolio 4: NoSQL and Advanced Database Models

**Project:** Apex Digital Bank Database  
**Course:** MIT 8103 — Advanced Database Systems  
**Database technologies:** MySQL 8 (relational core) and MongoDB Community Server 8.2.2 (document-oriented prototype)  
**MongoDB database:** `apex_digital_bank_nosql`  
**Environment:** Local macOS development environment, MongoDB Shell (`mongosh`)

## 1. Introduction and objectives

Apex Digital Bank is a fictional banking system designed to demonstrate advanced database principles in a realistic financial-services setting. Its relational MySQL schema models structured banking records and their relationships, including customers, accounts, financial transactions, and accounting entries. This portfolio evaluates a complementary NoSQL document model for data whose structure may evolve or vary between events.

The practical objectives were to:

1. Configure and connect to a local MongoDB instance.
2. Design collections for fraud events, customer activity logs, and transaction risk profiles.
3. Insert, retrieve, and modify nested JSON-like documents.
4. Create indexes supporting representative access patterns.
5. Execute aggregation pipelines for fraud reporting, activity reporting, and risk review.
6. Inspect an indexed query with MongoDB's execution statistics.
7. Evaluate the trade-offs between relational and document-oriented storage in a banking architecture.

The exercises use **synthetic demonstration data**, not real customer information.

## 2. Architecture and technology selection

### 2.1 Relational system of record

MySQL remains the proposed authoritative store for core banking entities and financially consequential state. In the Apex Digital Bank design, these include customer and account records, transaction status, and double-entry journal records. Structured relationships, foreign keys, transactional integrity, and consistency controls are especially important for these workloads.

### 2.2 Complementary MongoDB document store

MongoDB was selected for a prototype of event-centric operational data:

- **Fraud events:** Indicators, device context, geographic context, and investigation information can differ by alert type.
- **Customer activity logs:** Events from mobile and internet banking may carry different device attributes and metadata.
- **Transaction risk profiles:** Risk assessments can include different nested features, thresholds, and recommended actions.

MongoDB documents allow related contextual fields to be embedded within a single record. This can reduce the need for multiple joins when reviewing a fraud event, but it does not eliminate the need for careful schema governance, indexing, retention policies, and security.

**Architectural boundary:** The prototype does not replace MySQL's transactional ledger with MongoDB. In a production design, a reliable event-publication mechanism (for example, an outbox pattern with asynchronous consumers) would be needed to propagate relevant events from the relational system into MongoDB. That integration was **not implemented or tested** in this portfolio.

## 3. Local environment and collection setup

MongoDB Community Server was started locally and accessed through `mongosh` on `127.0.0.1:27017`. The connection test returned `{ ok: 1 }`. The working database was selected using:

```javascript
use apex_digital_bank_nosql
```

Three collections were created:

```javascript
db.createCollection("fraud_events");
db.createCollection("customer_activity_logs");
db.createCollection("transaction_risk_profiles");
```

The `show collections` command confirmed that all three collections existed.

**Environment limitation:** The MongoDB server displayed a warning that access control was not enabled. This is acceptable only for an isolated learning environment; authentication, least-privilege authorization, network restrictions, and encryption controls would be required before production use.

## 4. Document modelling

### 4.1 `fraud_events`

This collection records fraud-detection events and investigation context. The demonstrated documents contain fields such as:

| Field | Purpose |
|---|---|
| `event_id` | Human-readable event identifier |
| `transaction_reference` | Reference to the related banking transaction |
| `customer_id` | Customer identifier used for event correlation |
| `event_type` | Fraud or security event classification |
| `severity` | Risk severity, such as `HIGH` or `MEDIUM` |
| `risk_score` | Numerical risk score |
| `indicators` | Array of risk signals |
| `device` | Embedded device context, where available |
| `location` | Embedded location context, where available |
| `investigation` | Embedded investigation status and ownership |
| `investigation_notes` | Array of appended investigation notes |
| `detected_at` | Event timestamp |

For example, the high-severity event `FRD-2026-0001` relates to transaction `APX-TXN-0001` and includes a risk score of **92**, with indicators for a new device, high transaction value, and unusual location.

### 4.2 `customer_activity_logs`

This collection represents customer interactions with digital banking channels. Demonstrated fields include `customer_id`, `activity_type`, `channel`, `status`, nested `device`, optional `location`, optional `metadata`, and `occurred_at`.

The nested `metadata` structure supports different details for different activity types. For example, a successful mobile login recorded biometric authentication, while a failed internet banking login recorded a failure reason and attempt number.

### 4.3 `transaction_risk_profiles`

This collection represents risk assessments associated with transaction references. Fields include `transaction_reference`, `customer_id`, `overall_risk_score`, `risk_level`, nested `assessment`, `recommendation`, and `assessed_at`.

The `assessment` subdocument accommodates varying signals such as transaction velocity, geographic anomalies, device trust, or failed authentication attempts. This flexibility is useful when a risk engine adds new assessment features over time.

### 4.4 Modelling rationale

Embedded objects were used for information typically read together, such as device details and investigation state. Arrays were used for multiple indicators and investigation notes. Transaction and customer identifiers were retained as correlation keys rather than attempting to duplicate the entire relational customer or transaction record.

The prototype does **not** enforce referential integrity between MongoDB identifiers and MySQL records. A production integration would need validation, reconciliation, and a clear policy for missing or delayed source events.

## 5. CRUD operations and verification

### 5.1 Create

Sample documents were inserted into each collection using `insertMany()`. The MongoDB shell acknowledged successful inserts and returned generated `ObjectId` values. The demonstrated dataset contains:

| Collection | Verified document count |
|---|---:|
| `fraud_events` | 2 |
| `customer_activity_logs` | 2 |
| `transaction_risk_profiles` | 2 |

### 5.2 Read

The `find()` operation retrieved the stored fraud-event documents, confirming that scalar fields, arrays, embedded objects, and BSON date values were persisted and returned correctly.

### 5.3 Update of nested documents

A fraud investigation record was updated using `updateOne()` with both `$set` and `$push`:

```javascript
db.fraud_events.updateOne(
  { event_id: "FRD-2026-0001" },
  {
    $set: {
      "investigation.status": "UNDER_REVIEW",
      "investigation.review_priority": "URGENT",
      "investigation.last_reviewed_at": new Date()
    },
    $push: {
      investigation_notes: {
        action: "ESCALATED",
        reason: "High-risk transaction from an untrusted device",
        reviewed_by: "Fraud Operations",
        timestamp: new Date()
      }
    }
  }
);
```

The update response showed `acknowledged: true`, `matchedCount: 1`, and `modifiedCount: 1`. A subsequent read confirmed the `UNDER_REVIEW` status, `URGENT` priority, and appended `ESCALATED` note.

This demonstrates that a nested field can be updated and a history entry appended without replacing the complete document. **The appended array is a prototype investigation trail, not a tamper-evident or independently immutable audit log.**

### 5.4 Delete

Deletion was **not demonstrated** in the supplied evidence. Since fraud and activity records can be audit-relevant, the prototype intentionally focuses on create, read, and update operations. A production system would define retention, archival, and authorized deletion policies rather than casually deleting investigation history.

## 6. Index design

The following indexes were created during the practical exercises:

| Collection | Index name | Key pattern | Intended access pattern |
|---|---|---|---|
| `fraud_events` | `idx_fraud_customer_date` | `{ customer_id: 1, detected_at: -1 }` | Recent fraud events for a customer |
| `fraud_events` | `idx_fraud_severity_score` | `{ severity: 1, risk_score: -1 }` | Fraud review by severity and risk score |
| `customer_activity_logs` | `idx_activity_customer_date` | `{ customer_id: 1, occurred_at: -1 }` | Customer activity timeline |
| `transaction_risk_profiles` | `idx_risk_transaction_reference` | `{ transaction_reference: 1 }`, unique | Lookup by transaction reference and uniqueness within the collection |

Compound index field order matters. For the customer fraud timeline, the equality predicate on `customer_id` is followed by descending `detected_at`, matching the filter and sort of the demonstrated query.

The unique index on `transaction_reference` prevents duplicate risk-profile documents with the same indexed reference value under the collection's index rules. It does not guarantee that a referenced MySQL transaction exists.

## 7. Aggregation pipelines and results

### 7.1 Fraud severity summary

A `$group` pipeline calculated event counts, average risk scores, and maximum risk scores by severity, then sorted the groups by average risk score.

| Severity | Events | Average risk score | Maximum risk score |
|---|---:|---:|---:|
| `HIGH` | 1 | 92 | 92 |
| `MEDIUM` | 1 | 68 | 68 |

This query illustrates how document-oriented event data can support operational fraud reporting.

### 7.2 Customer activity by channel and outcome

A pipeline grouped activity logs by `channel` and `status`, used `$addToSet` to identify distinct customers, and calculated the number of distinct customers in a subsequent projection.

| Channel | Status | Activities | Unique customers |
|---|---|---:|---:|
| `INTERNET_BANKING` | `FAILED` | 1 | 1 |
| `MOBILE_APP` | `SUCCESS` | 1 | 1 |

This demonstrates a simple channel-level activity report; the sample is too small to infer meaningful operational trends.

### 7.3 High-risk transaction selection

A pipeline selected transaction risk profiles with `overall_risk_score >= 80`, projected selected assessment fields, and sorted by descending risk score.

The demonstrated result was:

- **Transaction:** `APX-TXN-0001`
- **Customer:** `1001`
- **Risk score:** `92`
- **Risk level:** `HIGH`
- **Recommendation:** `MANUAL_REVIEW`
- **New device:** `true`
- **Unusual location:** `true`

This illustrates retrieval of selected nested assessment features without requiring a fixed table column for every potential risk signal.

## 8. Query execution-plan analysis

The following query was examined with `explain("executionStats")`:

```javascript
db.fraud_events.find({
  customer_id: 1001
}).sort({
  detected_at: -1
}).explain("executionStats");
```

The screenshots showed the following results:

| Metric | Observed value |
|---|---|
| Query execution | Successful |
| Winning plan | `FETCH` with an `IXSCAN` input stage |
| Index name | `idx_fraud_customer_date` |
| Index key pattern | `{ customer_id: 1, detected_at: -1 }` |
| Documents returned (`nReturned`) | 1 |
| Index keys examined (`totalKeysExamined`) | 1 |
| Documents examined (`totalDocsExamined`) | 1 |
| Execution time (`executionTimeMillis`) | 9 ms |

**Interpretation:** MongoDB used the intended compound index to locate the matching customer's fraud event. The `IXSCAN` stage confirms index access, and `FETCH` indicates that the matching document was retrieved. The index's key order supports both the equality filter and descending timestamp sort.

**Performance limitation:** Only two fraud-event documents were present. The 9 ms measurement is a single observed execution time, not a benchmark. The evidence demonstrates **index selection**, not a statistically defensible speedup relative to a collection scan. A larger synthetic dataset, repeated measurements, and a controlled indexed-versus-unindexed comparison would be needed to quantify performance gains.

An earlier shell message, `ReferenceError: clear is not defined`, arose from attempting a terminal-clearing command in `mongosh`; it did not prevent the subsequent successful query analysis.

## 9. Relational versus document-oriented database comparison

| Consideration | MySQL relational model | MongoDB document model | Apex Digital Bank decision |
|---|---|---|---|
| Data organisation | Tables, rows, defined relationships | Collections of BSON documents with nested structures | MySQL for core banking; MongoDB for contextual event data |
| Schema evolution | Typically requires managed schema changes | Flexible document shapes; validation can still be enforced | Useful for evolving risk signals and activity metadata |
| Referential integrity | Foreign keys and relational constraints | No cross-database foreign keys to MySQL | Keep authoritative entities in MySQL; reconcile correlation IDs |
| Multi-record financial consistency | Transactional controls suited to ledger posting | Transactions are supported, but document flexibility does not replace ledger design | Do not move authoritative accounting to the NoSQL prototype |
| Query patterns | Joins and SQL reporting | Document queries and aggregation pipelines | Use each system for its intended access patterns |
| Indexing | B-tree and other supported index mechanisms | Single-field and compound indexes, among other index types | Design indexes from observed filters and sort orders |
| Audit and governance | Constraints, privileges, and controlled append-only patterns | Requires explicit access controls, retention, and audit strategy | Additional controls needed for either system |

MongoDB is not inherently faster than MySQL. Performance depends on data shape, query patterns, index design, workload, hardware, and consistency requirements. The practical result supports MongoDB's suitability for the **demonstrated document access patterns**, not a universal performance advantage.

## 10. Proposed production considerations

The following are **recommendations, not implemented features**:

1. **Secure deployment:** Enable authentication, role-based permissions, TLS, network isolation, encryption at rest where applicable, and appropriate secret management.
2. **Schema governance:** Apply MongoDB schema validation to important fields, permitted risk levels, and required identifiers while allowing controlled extension of event metadata.
3. **Reliable integration:** Publish transactional events from MySQL through an outbox or similarly reliable mechanism; design consumers for retries, idempotency, and reconciliation.
4. **Auditability:** Use protected, append-only investigation history or an independently controlled audit service where regulatory evidence is required.
5. **Retention:** Define retention and archival rules for fraud events and activity logs in accordance with organisational and applicable legal requirements.
6. **Scalability:** Evaluate replica sets, monitoring, backup and restore procedures, and partitioning/sharding only when supported by workload measurements and availability requirements.
7. **Operational observability:** Track query latency, index usage, slow queries, storage growth, and failed event delivery.

No production deployment, cross-database event synchronization, replica set, or sharded cluster was demonstrated as part of this portfolio.

## 11. Evidence register

The following screenshot filenames correspond to the practical evidence collected during this portfolio. Files should be stored under `04-nosql/screenshots/`.

| Evidence | Filename | What it demonstrates |
|---|---|---|
| 08 | `08-fraud-risk-aggregation.png` | Fraud aggregation query and results |
| 09 | `09-customer-activity-aggregation.png` | Activity aggregation query and results |
| 10 | `10-high-risk-transactions.png` | High-risk profile query and result |
| 11 | `11-nested-document-update.png` | Successful nested update operation |
| 12 | `12-nested-document-update-verification.png` | Retrieved updated investigation fields and note |
| 13 | `13-mongodb-index-execution-plan.png` | `IXSCAN` winning plan and index name |
| 14 | `14-mongodb-index-execution-statistics.png` | Execution statistics and examined-record counts |

Earlier setup, insertion, retrieval, and index-creation screenshots should also be retained under their existing filenames. The evidence register above does not claim that those earlier files were independently inspected in this report.

## 12. Limitations

- The prototype contains two documents per collection, which is adequate for demonstrating functionality but insufficient for realistic workload benchmarking.
- The data is synthetic and does not represent actual fraud rates or customer behaviour.
- The MongoDB instance was local and had access control disabled during testing.
- Cross-database replication, event streaming, automated reconciliation, and production monitoring were not implemented.
- The test did not demonstrate deletion, concurrency behaviour, or multi-document transactions in MongoDB.
- A single execution-plan result cannot establish comparative database performance.

## 13. Conclusion

The Portfolio 4 practical successfully demonstrated MongoDB collection creation, insertion and retrieval of nested documents, targeted updates with `$set` and `$push`, compound and unique indexes, three aggregation use cases, and index-plan inspection. The query planner selected `idx_fraud_customer_date` for a customer-specific fraud timeline, examining one index key and one document in the observed run.

For Apex Digital Bank, the proposed architecture retains MySQL as the authoritative system of record for financially critical data while using MongoDB as a complementary store for flexible fraud, activity, and risk-assessment documents. This separation reflects the distinct data-integrity and query requirements of each workload. Further testing and security hardening would be necessary before production deployment.

## 14. AI assistance and reproducibility statement

AI assistance was used to help structure explanations, prepare example MongoDB commands, and draft this technical analysis. The student executed the commands in a local MongoDB environment and supplied screenshots of observed results. The analysis distinguishes observed outcomes from proposed architectural improvements. Any final submission should be reviewed for accuracy, supplemented with the actual command scripts and screenshots, and aligned with the institution's AI-use and citation requirements.

### Recommended repository artifacts

```text
04-nosql/
├── analysis.md
├── mongodb/
│   ├── 01-create-collections.js
│   ├── 02-seed-documents.js
│   ├── 03-create-indexes.js
│   ├── 04-aggregation-queries.js
│   ├── 05-nested-update.js
│   └── 06-explain-index.js
└── screenshots/
    ├── ... earlier setup and CRUD evidence ...
    ├── 08-fraud-risk-aggregation.png
    ├── 09-customer-activity-aggregation.png
    ├── 10-high-risk-transactions.png
    ├── 11-nested-document-update.png
    ├── 12-nested-document-update-verification.png
    ├── 13-mongodb-index-execution-plan.png
    └── 14-mongodb-index-execution-statistics.png
```

**Note:** The script filenames above describe the recommended repository organisation. This report does not assert that all six `.js` files have already been created.
