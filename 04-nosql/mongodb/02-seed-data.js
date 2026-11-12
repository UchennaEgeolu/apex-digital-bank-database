// Synthetic academic demonstration records; rerunnable without duplicates.
const bankDb = db.getSiblingDB('apex_digital_bank_nosql');
const fraud = [
  {event_id:'FRD-2026-0001', transaction_reference:'APX-TXN-0001',customer_id:1001,event_type:'UNUSUAL_TRANSFER',severity:'HIGH',risk_score:92,indicators:['NEW_DEVICE','HIGH_TRANSACTION_VALUE','UNUSUAL_LOCATION'],device:{type:'mobile',operating_system:'Android',trusted:false},location:{country:'Nigeria',city:'Lagos'},investigation:{status:'OPEN',assigned_team:'Fraud Operations'},detected_at:new Date('2026-11-10T09:30:00Z')},
  {event_id:'FRD-2026-0002', transaction_reference:'APX-TXN-0002',customer_id:1002,event_type:'MULTIPLE_FAILED_ATTEMPTS',severity:'MEDIUM',risk_score:68,indicators:['FAILED_PIN_ATTEMPTS','UNRECOGNISED_DEVICE'],investigation:{status:'UNDER_REVIEW',assigned_team:'Security Operations'},detected_at:new Date('2026-11-11T14:15:00Z')}
];
const activity = [
  {customer_id:1001,activity_type:'LOGIN',channel:'MOBILE_APP',status:'SUCCESS',device:{device_id:'DEV-001',operating_system:'Android',app_version:'2.4.1'},location:{city:'Lagos',country:'Nigeria'},metadata:{authentication_method:'BIOMETRIC'},occurred_at:new Date('2026-11-10T09:25:00Z')},
  {customer_id:1002,activity_type:'LOGIN',channel:'INTERNET_BANKING',status:'FAILED',device:{device_id:'DEV-002',operating_system:'macOS'},metadata:{failure_reason:'INVALID_PASSWORD',attempt_number:3},occurred_at:new Date('2026-11-11T14:10:00Z')}
];
const profiles = [
  {transaction_reference:'APX-TXN-0001',customer_id:1001,overall_risk_score:92,risk_level:'HIGH',assessment:{transaction_velocity:{transactions_last_hour:12,threshold:5},geographic_risk:{unusual_location:true},device_risk:{new_device:true,trusted:false}},recommendation:'MANUAL_REVIEW',assessed_at:new Date('2026-11-10T09:30:00Z')},
  {transaction_reference:'APX-TXN-0002',customer_id:1002,overall_risk_score:68,risk_level:'MEDIUM',assessment:{authentication_risk:{failed_attempts:3}},recommendation:'STEP_UP_AUTHENTICATION',assessed_at:new Date('2026-11-11T14:15:00Z')}
];
for (const d of fraud) bankDb.fraud_events.updateOne({event_id:d.event_id},{$setOnInsert:d},{upsert:true});
for (const d of activity) bankDb.customer_activity_logs.updateOne({customer_id:d.customer_id,activity_type:d.activity_type,occurred_at:d.occurred_at},{$setOnInsert:d},{upsert:true});
for (const d of profiles) bankDb.transaction_risk_profiles.updateOne({transaction_reference:d.transaction_reference},{$setOnInsert:d},{upsert:true});
for (const name of ['fraud_events','customer_activity_logs','transaction_risk_profiles']) print(`${name}: ${bankDb.getCollection(name).countDocuments({})} documents`);
