'use strict';

process.env.NODE_ENV = 'test';

const { db } = require('../config/database');
const { SavingsAccountingService } = require('../services/savings-accounting.service');

describe('SavingsAccountingService cycle scoping', () => {
  let conn;
  let userId;
  let cycleA;
  let cycleB;
  let goalId;
  let efGoalId;

  beforeAll(async () => {
    conn = await db.getConnection();

    const [uRes] = await conn.execute(
      `INSERT INTO users (full_name, email, password_hash, is_verified, is_onboarded)
       VALUES ('Savings Acc', CONCAT(UUID(), '@savings.test'), 'hash', 1, 1)`
    );
    userId = uRes.insertId;

    const [cA] = await conn.execute(
      `INSERT INTO financial_cycles (user_id, start_date, end_date, status, expected_income, policy_version)
       VALUES (?, '2026-01-01', '2026-01-31', 'closed', 1000, '1.0')`,
      [userId]
    );
    cycleA = cA.insertId;

    const [cB] = await conn.execute(
      `INSERT INTO financial_cycles (user_id, start_date, end_date, status, expected_income, policy_version)
       VALUES (?, '2026-02-01', '2026-02-28', 'open', 1000, '1.0')`,
      [userId]
    );
    cycleB = cB.insertId;

    const [gRes] = await conn.execute(
      `INSERT INTO goals (user_id, name, target_amount, current_balance, status, goal_type, is_system_managed)
       VALUES (?, 'Laptop', 500, 0, 'active', 'laptop', FALSE)`,
      [userId]
    );
    goalId = gRes.insertId;

    const [efRes] = await conn.execute(
      `INSERT INTO goals (user_id, name, target_amount, current_balance, status, goal_type, is_system_managed)
       VALUES (?, 'Emergency Fund', 2000, 0, 'active', 'emergency_fund', TRUE)`,
      [userId]
    );
    efGoalId = efRes.insertId;

    await conn.execute(
      `INSERT INTO goal_transactions
         (user_id, goal_id, cycle_id, amount, transaction_type, source_type)
       VALUES
         (?, ?, ?, 40, 'contribution', 'user_contribution'),
         (?, ?, ?, 90, 'contribution', 'user_contribution'),
         (?, ?, ?, 10, 'contribution', 'settlement_emergency_fund'),
         (?, ?, ?, 25, 'contribution', 'settlement_emergency_fund')`,
      [userId, goalId, cycleA, userId, goalId, cycleB, userId, efGoalId, cycleA, userId, efGoalId, cycleB]
    );
  });

  afterAll(async () => {
    await conn.execute('DELETE FROM goal_transactions WHERE user_id = ?', [userId]);
    await conn.execute('DELETE FROM goals WHERE user_id = ?', [userId]);
    await conn.execute('DELETE FROM financial_cycles WHERE user_id = ?', [userId]);
    await conn.execute('DELETE FROM users WHERE id = ?', [userId]);
    conn.release();
  });

  it('getActualGoalContributions only sums the requested cycle', async () => {
    const a = await SavingsAccountingService.getActualGoalContributions(userId, cycleA);
    const b = await SavingsAccountingService.getActualGoalContributions(userId, cycleB);
    expect(a).toBe(40);
    expect(b).toBe(90);
  });

  it('getEmergencyFundFundedThisCycle only sums the requested cycle', async () => {
    const a = await SavingsAccountingService.getEmergencyFundFundedThisCycle(userId, cycleA);
    const b = await SavingsAccountingService.getEmergencyFundFundedThisCycle(userId, cycleB);
    expect(a).toBe(10);
    expect(b).toBe(25);
  });
});
