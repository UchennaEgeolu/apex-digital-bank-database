// Indexes support customer timelines, fraud prioritisation, and unique risk profiles.
const bankDb = db.getSiblingDB('apex_digital_bank_nosql');
print(bankDb.fraud_events.createIndex({customer_id:1,detected_at:-1},{name:'idx_fraud_customer_date'}));
print(bankDb.fraud_events.createIndex({severity:1,risk_score:-1},{name:'idx_fraud_severity_score'}));
print(bankDb.fraud_events.createIndex({event_id:1},{name:'uq_fraud_event_id',unique:true}));
print(bankDb.customer_activity_logs.createIndex({customer_id:1,occurred_at:-1},{name:'idx_activity_customer_date'}));
print(bankDb.transaction_risk_profiles.createIndex({transaction_reference:1},{name:'idx_risk_transaction_reference',unique:true}));
for (const name of ['fraud_events','customer_activity_logs','transaction_risk_profiles']) {
  print(`Indexes for ${name}:`);printjson(bankDb.getCollection(name).getIndexes());
}
