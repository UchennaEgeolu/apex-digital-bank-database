// Print results explicitly: mongosh aggregation cursors can otherwise display nothing in scripts.
const bankDb = db.getSiblingDB('apex_digital_bank_nosql');
print('Fraud events by severity:');
printjson(bankDb.fraud_events.aggregate([
  {$group:{_id:'$severity',total_events:{$sum:1},average_risk_score:{$avg:'$risk_score'},highest_risk_score:{$max:'$risk_score'}}},
  {$sort:{average_risk_score:-1}}
]).toArray());
print('Customer activity by channel and status:');
printjson(bankDb.customer_activity_logs.aggregate([
  {$group:{_id:{channel:'$channel',status:'$status'},total_activities:{$sum:1},unique_customers:{$addToSet:'$customer_id'}}},
  {$project:{_id:0,channel:'$_id.channel',status:'$_id.status',total_activities:1,unique_customer_count:{$size:'$unique_customers'}}},
  {$sort:{total_activities:-1,channel:1}}
]).toArray());
print('High-risk transaction assessments (score >= 80):');
printjson(bankDb.transaction_risk_profiles.aggregate([
  {$match:{overall_risk_score:{$gte:80}}},
  {$project:{_id:0,transaction_reference:1,customer_id:1,overall_risk_score:1,risk_level:1,recommendation:1,new_device:'$assessment.device_risk.new_device',unusual_location:'$assessment.geographic_risk.unusual_location'}},
  {$sort:{overall_risk_score:-1}}
]).toArray());
