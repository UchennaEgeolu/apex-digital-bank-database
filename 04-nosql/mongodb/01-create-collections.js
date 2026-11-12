// Apex Digital Bank | Portfolio 4 | MongoDB collections
// Run: mongosh "mongodb://127.0.0.1:27017/apex_digital_bank_nosql" 01-create-collections.js
const bankDb = db.getSiblingDB('apex_digital_bank_nosql');
for (const name of ['fraud_events', 'customer_activity_logs', 'transaction_risk_profiles']) {
  if (!bankDb.getCollectionNames().includes(name)) {
    bankDb.createCollection(name);
    print(`Created ${name}`);
  } else print(`Already exists: ${name}`);
}
printjson(bankDb.getCollectionNames().sort());
