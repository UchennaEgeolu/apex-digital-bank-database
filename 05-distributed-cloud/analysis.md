# Portfolio 5: Distributed and Cloud Database Exercise

**Course:** MIT 8103 — Advanced Database Systems  
**Case study:** Apex Digital Bank  
**Environment:** Local Docker Compose simulation using MySQL 8.0 (observed server version: 8.0.46)  
**Database:** `apex_distributed`

## 1. Objective and scope

This exercise demonstrates a distributed relational database arrangement for Apex Digital Bank using one writable MySQL primary and one MySQL replica. The practical objectives were to configure replication, verify propagation of banking-style transaction records, inspect replication health, and restrict direct writes on the replica. The exercise also evaluates consistency, availability, security, and potential deployment to managed cloud infrastructure.

**Scope clarification:** Both database instances ran as Docker containers on the same development computer. This is a local simulation of a distributed database topology, **not** a production multi-host or cloud deployment. It demonstrates data replication between independent MySQL server instances but does not establish geographic redundancy, automatic failover, or cloud availability.

## 2. Architecture and environment

The topology comprises two MySQL 8.0 instances connected through Docker Compose networking:

| Component | Role | Container | Host endpoint | MySQL server ID |
|---|---|---|---|---|
| Primary | Accepts application writes and emits binary log events | `apex-mysql-primary` | `127.0.0.1:3307` | `1` |
| Replica | Receives and applies primary transactions; serves candidate read workloads | `apex-mysql-replica` | `127.0.0.1:3308` | `2` |

The primary uses row-based binary logging (`binlog_format=ROW`), a binary log (`mysql-bin`), GTID mode (`gtid_mode=ON`), and GTID consistency enforcement (`enforce_gtid_consistency=ON`). The replica has its own server ID and GTID mode. Replication is configured with `SOURCE_AUTO_POSITION=1`, so it follows GTID-based positioning rather than requiring a manually maintained binary-log file and offset.

The MySQL schema used for the replication demonstration is `apex_distributed`. The test table is `replication_test`; it is a focused proof-of-concept and does not represent the full 45-table operational banking schema from Portfolio 1.

### 2.1 Logical data flow

```text
Banking application / SQL client
              |
              | Writes (INSERT / UPDATE / DELETE)
              v
     MySQL PRIMARY (server_id=1)
       apex_distributed
              |
              | Row-based binary log + GTIDs
              v
     MySQL REPLICA (server_id=2)
       apex_distributed
              |
              | Replication receiver and applier
              v
        Read / reporting queries
```

Replication is **asynchronous** in this configuration. A successful primary commit does not by itself guarantee that the replica has already applied that transaction. A read from the replica may briefly return stale data.

## 3. Implementation procedure

### 3.1 Container setup

The database services were defined in `mysql/compose.yml`. Their database name and root-password variables are supplied from a local `.env` file in the `05-distributed-cloud` directory. A safe `.env.example` contains placeholders and is suitable for version control.

The Compose configuration was successfully validated from `05-distributed-cloud` using:

```bash
docker compose --env-file .env -f mysql/compose.yml config --quiet
```

Both containers were confirmed running using:

```bash
docker compose --env-file .env -f mysql/compose.yml ps
```

Observed host port mappings were `3307:3306` for the primary and `3308:3306` for the replica, both bound to `127.0.0.1` on the host. This limits host-side exposure but does not replace access control on the Docker network.

### 3.2 Primary configuration

The primary was checked using:

```sql
SELECT
    @@server_id AS server_id,
    @@log_bin AS binary_logging,
    @@gtid_mode AS gtid_mode;

SHOW MASTER STATUS;
```

The observed result was `server_id = 1`, binary logging enabled (`1`), and GTID mode `ON`. `SHOW MASTER STATUS` returned a binary-log file and executed GTID set, confirming binary-log availability. The legacy `SHOW MASTER STATUS` syntax worked in the MySQL 8.0.46 environment used for this exercise.

A dedicated replication account was created and granted `REPLICATION SLAVE` and `REPLICATION CLIENT` privileges. These grants were verified with `SHOW GRANTS`. The credentials are intentionally omitted from this report.

### 3.3 Replica configuration

The replica was confirmed to have `server_id = 2` and GTID mode `ON`. Its replication source was configured to connect to the primary service on the Docker network, using GTID auto-positioning:

```sql
CHANGE REPLICATION SOURCE TO
    SOURCE_HOST = 'mysql-primary',
    SOURCE_PORT = 3306,
    SOURCE_USER = 'replicator',
    SOURCE_AUTO_POSITION = 1,
    GET_SOURCE_PUBLIC_KEY = 1;
```

**Note:** The actual setup also supplied the replication account password via `SOURCE_PASSWORD`. The password is deliberately excluded from the documented example. `GET_SOURCE_PUBLIC_KEY=1` supports the authentication configuration used in this local demonstration; a production deployment should use authenticated TLS and appropriate credential management.

Replication was started and inspected with:

```sql
START REPLICA;
SHOW REPLICA STATUS\G
```

The observed status included:

| Replication indicator | Observed result |
|---|---|
| `Replica_IO_Running` | `Yes` |
| `Replica_SQL_Running` | `Yes` |
| `Replica_IO_State` | Waiting for source to send event |
| `Seconds_Behind_Source` | `0` at the time of inspection |
| `Last_IO_Errno` | `0` |
| `Last_SQL_Errno` | `0` |
| Replica SQL state | Read all relay log; waiting for more updates |

These observations demonstrate that the replica was connected, receiving events, and applying available transactions at the time of inspection. The lag reading is a point-in-time status, **not** a measured latency service-level guarantee.

## 4. Replication verification

### 4.1 Test dataset

On the primary, a simple banking-style transaction table was created:

```sql
USE apex_distributed;

CREATE TABLE replication_test (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_reference VARCHAR(50) NOT NULL UNIQUE,
    amount DECIMAL(18,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO replication_test
    (transaction_reference, amount, status)
VALUES
    ('APX-REP-001', 150000.00, 'SUCCESS'),
    ('APX-REP-002',  75000.00, 'SUCCESS'),
    ('APX-REP-003',  25000.00, 'PENDING');

SELECT * FROM replication_test;
```

The primary returned three rows. The same query was then executed on the replica, which returned the matching three transaction references, amounts, and statuses:

| Transaction reference | Amount (NGN, synthetic) | Status | Primary | Replica |
|---|---:|---|---|---|
| APX-REP-001 | 150,000.00 | SUCCESS | Present | Present |
| APX-REP-002 | 75,000.00 | SUCCESS | Present | Present |
| APX-REP-003 | 25,000.00 | PENDING | Present | Present |

**Result:** The table definition and inserted rows were successfully propagated from primary to replica. This is direct evidence of functioning replication for the tested workload.

### 4.2 Replica write protection

Initial inspection showed the replica's `read_only` and `super_read_only` variables both set to `0`. To prevent accidental direct writes, both settings were enabled:

```sql
SET GLOBAL read_only = ON;
SET GLOBAL super_read_only = ON;

SELECT
    @@server_id AS server_id,
    @@read_only AS read_only,
    @@super_read_only AS super_read_only;
```

The resulting values were `server_id = 2`, `read_only = 1`, and `super_read_only = 1`.

A subsequent attempt to insert `APX-REP-004` directly on the replica failed with:

```text
ERROR 1290 (HY000): The MySQL server is running with the
--super-read-only option so it cannot execute this statement
```

**Result:** Direct application writes were blocked while replication remained configured. The test demonstrates an important control for a primary–replica topology: clients should direct mutations to the primary, not to a read replica.

**Persistence caveat:** The observed settings were applied using `SET GLOBAL`, which alone does not prove that they survive container/server restarts. They should also be set in the replica's startup configuration (for example `--read-only=ON` and `--super-read-only=ON`) and reverified after a controlled restart. That persistence test is not yet documented as completed.

## 5. Analysis of distributed database properties

### 5.1 Data consistency

The experiment demonstrates eventual convergence: writes committed on the primary appeared on the replica. Because replication is asynchronous, there can be a period between the primary commit and replica application during which the two instances return different results. Therefore, the architecture does not provide guaranteed immediate read-after-write consistency from the replica.

For a banking system, balance-affecting operations, posting confirmations, and other critical decisions should use authoritative primary data or explicitly enforce a suitable consistency mechanism. Replicas are more appropriate for reporting, analytics, and reads that tolerate bounded staleness.

### 5.2 Availability and resilience

The replica creates an additional copy of the data and can support read scaling. However, the tested setup places both containers on a single host, creating a shared failure domain. A host failure would make both unavailable. The experiment did **not** implement or test automatic failover, replica promotion, application reconnection, or recovery-point/recovery-time objectives.

In a production design, separate availability zones or hosts, monitoring, automated failover, backups, and tested recovery procedures would be needed. Asynchronous failover can also risk losing transactions that were committed on the old primary but had not yet reached the promoted replica.

### 5.3 Performance and scalability

Primary–replica replication can offload suitable read-only workloads from the primary. It does not horizontally distribute writes: all authoritative writes still go to the primary. The replica also consumes resources to receive and apply events. This exercise verified functional replication but did **not** benchmark throughput, query latency, or scaling efficiency; no performance improvement is claimed.

### 5.4 CAP and partition considerations

The CAP theorem concerns behavior under network partitions. This demonstration did not induce a partition, so it cannot empirically classify the system's partition behavior. Operational choices such as whether the application continues reading stale replica data, rejects writes, or promotes a replica influence the consistency and availability trade-offs during an outage. These trade-offs require explicit application and failover policies rather than a simple label.

### 5.5 Security

The Compose setup uses environment variables instead of embedding root passwords directly in the committed YAML file. The repository `.gitignore` was verified to ignore `05-distributed-cloud/.env`:

```text
.gitignore:2:.env    05-distributed-cloud/.env
```

The committed `.env.example` contains placeholder passwords only. These steps reduce accidental credential disclosure through Git, but they are not encryption or secret rotation. Additional production measures include secret-manager integration, dedicated least-privilege application users, TLS for database and replication connections, network segmentation, audit logging, and credential rotation. Root accounts should not be used for normal application traffic.

## 6. Cloud deployment mapping

A realistic cloud implementation could replace the two local containers with a managed MySQL primary and one or more managed read replicas, such as an Amazon RDS for MySQL deployment. The logical roles would remain similar, but a managed service can supply automated provisioning, backup options, health monitoring, and configurable high-availability features.

A production architecture for Apex Digital Bank would consider:

1. **Separate failure domains:** Deploy database capacity across distinct availability zones where supported.
2. **Controlled write endpoint:** Route all transactional mutations to the authoritative writer.
3. **Read routing:** Send reporting and other stale-tolerant queries to replicas; send consistency-critical reads to the writer.
4. **Recovery:** Define backups, point-in-time recovery, failover procedures, RPO, and RTO; test them regularly.
5. **Monitoring:** Track replica lag, replication errors, CPU, storage, connections, and application error rates.
6. **Security and governance:** Use private networking, encrypted connections and storage, managed secrets, least privilege, audit trails, and regulatory data-handling controls.

**No cloud resources were provisioned or tested as part of this exercise.** This section is an architectural mapping, not a claim of cloud deployment.

## 7. Results summary

| Test | Evidence | Outcome |
|---|---|---|
| Docker Compose configuration validation | `config --quiet` completed without errors | Pass |
| Container availability | `docker compose ... ps` showed both services `Up` | Pass |
| Primary binary logging and GTID | `@@log_bin=1`, `@@gtid_mode=ON` | Pass |
| Replication account privileges | `SHOW GRANTS` returned replication privileges | Pass |
| Replica connection and application | IO and SQL threads `Yes`, errors `0` | Pass |
| Replication of test data | Three matching records on primary and replica | Pass |
| Replica read-only enforcement | `read_only=1`, `super_read_only=1` | Pass |
| Rejection of direct replica write | MySQL error 1290 | Pass |
| Persistence of read-only settings after restart | Not yet verified | Pending |
| Automated failover / recovery | Not implemented or tested | Out of scope |
| Actual cloud deployment | Not performed | Out of scope |

## 8. Screenshot evidence

Store relevant screenshots in `05-distributed-cloud/screenshots/`. Suggested descriptive filenames for the captured evidence are:

- `01-primary-binlog-gtid-status.png` — primary server ID, binary logging, GTID mode, and binary-log status.
- `02-replication-user-grants.png` — replication account permissions; redact credentials if visible.
- `03-replica-status-running.png` — `SHOW REPLICA STATUS\G`, including IO/SQL threads and lag.
- `04-primary-test-transactions.png` — three inserted rows on the primary.
- `05-replica-replicated-transactions.png` — matching rows on the replica.
- `06-replica-read-only-enabled.png` — read-only and super-read-only values both `1`.
- `07-replica-write-rejected.png` — failed direct insert with MySQL error 1290.
- `08-compose-config-and-containers.png` — successful configuration validation and both running containers.
- `09-env-gitignore-verification.png` — `.env` exclusion confirmed by Git.

Only cite or include screenshots that were actually captured. Avoid committing screenshots containing live credentials or sensitive environment values.

## 9. Limitations and future improvements

This proof-of-concept uses two MySQL instances on one laptop. It does not establish true infrastructure fault tolerance, network partition behavior, production-grade secret management, automatic failover, or quantitative performance improvements. Replication was tested with three synthetic transactions; this is adequate as a functional demonstration but not as a production reliability or load test.

Possible next exercises include a controlled restart to verify persistent replica read-only settings; a primary update/delete propagation test; a controlled replica-stop/restart to observe catch-up; measuring replica lag under load; and documenting manual failover and recovery. These should be performed with a clear rollback plan and must not be reported as completed until evidence exists.

## 10. Conclusion

The Apex Digital Bank Portfolio 5 exercise successfully established **GTID-based asynchronous MySQL primary–replica replication** in Docker. Both instances ran independently, the replica's receiver and applier threads were healthy at inspection, three synthetic banking transaction records replicated correctly, and direct replica writes were rejected after enabling read-only controls.

The exercise demonstrates the fundamentals of data replication and read separation while also exposing an important architectural distinction: **replication is not the same as guaranteed high availability or strong consistency**. A production banking deployment would need independent failure domains, carefully defined consistency rules, robust security, observability, backup and recovery, and tested failover procedures.
