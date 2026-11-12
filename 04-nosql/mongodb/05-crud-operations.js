
// Portfolio 4: MongoDB CRUD Operations and Query Execution Analysis
// Apex Digital Bank
// Demonstrates READ, UPDATE ($set + $push), and index-backed EXPLAIN.
// CREATE is handled in 02-seed-data.js.
// Fraud records are retained; no destructive DELETE operations.

const bankDb = db.getSiblingDB('apex_digital_bank_nosql');

// 1. READ: Retrieve an existing fraud event
print('READ fraud event:');

printjson(
  bankDb.fraud_events.findOne({
    event_id: 'FRD-2026-0001'
  })
);

// 2. UPDATE: Escalate the fraud investigation
// Idempotent: prevents duplicate escalation notes.

const event = bankDb.fraud_events.findOne({
  event_id: 'FRD-2026-0001'
});

if (
  event &&
  !(event.investigation_notes || []).some(
    note => note.action === 'ESCALATED'
  )
) {
  print('UPDATE investigation and append an investigation note:');

  printjson(
    bankDb.fraud_events.updateOne(
      { event_id: 'FRD-2026-0001' },
      {
        $set: {
          'investigation.status': 'UNDER_REVIEW',
          'investigation.review_priority': 'URGENT',
          'investigation.last_reviewed_at': new Date()
        },
        $push: {
          investigation_notes: {
            action: 'ESCALATED',
            reason: 'High-risk transaction from an untrusted device',
            reviewed_by: 'Fraud Operations',
            timestamp: new Date()
          }
        }
      }
    )
  );
} else {
  print('Escalation already recorded (or event missing).');
}

// 3. READ: Verify the updated investigation
// Correct MongoDB projection syntax for findOne().

print('READ updated investigation:');

printjson(
  bankDb.fraud_events.findOne(
    { event_id: 'FRD-2026-0001' },
    {
      _id: 0,
      event_id: 1,
      severity: 1,
      investigation: 1,
      investigation_notes: 1
    }
  )
);

// 4. EXPLAIN: Verify index-backed fraud timeline query

print('EXPLAIN: Customer fraud timeline (IXSCAN expected):');

const plan = bankDb.fraud_events
  .find({ customer_id: 1001 })
  .sort({ detected_at: -1 })
  .explain('executionStats');

printjson({
  winningPlan: plan.queryPlanner.winningPlan,
  executionStats: plan.executionStats
});

print('MongoDB CRUD operations completed successfully.');
