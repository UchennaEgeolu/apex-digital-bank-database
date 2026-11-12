# Apex Digital Bank — MongoDB Portfolio 4

Synthetic banking fraud analytics, customer activity logs, and transaction risk assessments. MongoDB 8.x / `mongosh`.

## Execute from repository root

```bash
mongosh "mongodb://127.0.0.1:27017/apex_digital_bank_nosql" 04-nosql/mongodb/01-create-collections.js
mongosh "mongodb://127.0.0.1:27017/apex_digital_bank_nosql" 04-nosql/mongodb/02-seed-data.js
mongosh "mongodb://127.0.0.1:27017/apex_digital_bank_nosql" 04-nosql/mongodb/03-indexes.js
mongosh "mongodb://127.0.0.1:27017/apex_digital_bank_nosql" 04-nosql/mongodb/04-aggregations.js
mongosh "mongodb://127.0.0.1:27017/apex_digital_bank_nosql" 04-nosql/mongodb/05-crud-operations.js
```

Or copy the files into any folder and replace the path in each command.

The seed script uses upserts and can be rerun. The CRUD demonstration updates the first fraud case once, preserving the investigation history. Data is synthetic. No connection to the relational MySQL database is established by these scripts; shared customer IDs and transaction references are illustrative only.

## Evidence to capture

1. Collection names and document counts (2 each).
2. Nested fraud documents and customer activity documents.
3. Index listings and `IXSCAN` in query explain output.
4. Aggregation outputs for severity, channel, and high-risk profiles.
5. Investigation update and appended note.

**Security:** The local MongoDB instance shown in the exercise had access control disabled. Use only loopback access for this local demonstration; enable authentication, least privilege, and network restrictions in any shared or cloud environment.
