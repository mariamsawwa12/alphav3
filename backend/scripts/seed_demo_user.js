#!/usr/bin/env node
/**
 * Seeds a fully onboarded demo user with an open cycle, sample activity, and a goal.
 *
 * Usage (from backend/):
 *   node scripts/seed_demo_user.js
 *
 * Credentials (Jordan local phone in the app = 9 digits starting with 7):
 *   Phone:    790000001
 *   Password: DemoPass123!
 */

'use strict';

const path = require('path');
const bcrypt = require('bcrypt');
const dotenv = require('dotenv');

dotenv.config({ path: path.resolve(__dirname, '..', '.env') });

const { db } = require('../src/config/database');
const { env } = require('../src/config/env');
const { CycleService } = require('../src/services/cycle.service');

const DEMO = {
  fullName: 'Alpha Demo',
  email: 'demo@alpha.app',
  phoneLocal: '790000001',
  phoneE164: '+962790000001',
  password: 'DemoPass123!',
  birthDate: '1998-05-15',
  income: 800,
  paymentDay: 1,
  needsBps: 5000,
  wantsBps: 3000,
  savingsBps: 2000,
};

async function upsertDemoUser(conn) {
  const passwordHash = await bcrypt.hash(DEMO.password, env.bcryptSaltRounds);

  const [existing] = await conn.execute(
    `SELECT id FROM users WHERE phone = ? OR email = ? LIMIT 1`,
    [DEMO.phoneE164, DEMO.email]
  );

  let userId;
  if (existing.length > 0) {
    userId = existing[0].id;
    await conn.execute(
      `UPDATE users
       SET full_name = ?, phone = ?, email = ?, birth_date = ?, password_hash = ?,
           is_verified = 1, is_onboarded = 1, account_status = 'active'
       WHERE id = ?`,
      [DEMO.fullName, DEMO.phoneE164, DEMO.email, DEMO.birthDate, passwordHash, userId]
    );
    console.log(`Updated existing demo user id=${userId}`);
  } else {
    const [res] = await conn.execute(
      `INSERT INTO users
         (full_name, phone, email, birth_date, password_hash, is_verified, is_onboarded, account_status)
       VALUES (?, ?, ?, ?, ?, 1, 1, 'active')`,
      [DEMO.fullName, DEMO.phoneE164, DEMO.email, DEMO.birthDate, passwordHash]
    );
    userId = res.insertId;
    console.log(`Created demo user id=${userId}`);
  }

  await conn.execute(
    `INSERT INTO user_profiles (user_id, full_name)
     VALUES (?, ?)
     ON DUPLICATE KEY UPDATE full_name = VALUES(full_name)`,
    [userId, DEMO.fullName]
  ).catch(async () => {
    // Some schemas use different profile columns — best-effort.
    try {
      await conn.execute(
        `INSERT IGNORE INTO user_profiles (user_id) VALUES (?)`,
        [userId]
      );
    } catch (_) { /* optional table */ }
  });

  await conn.execute(
    `INSERT INTO financial_profiles
       (user_id, expected_monthly_income, payment_day, detected_tier, currency, timezone, onboarding_status)
     VALUES (?, ?, ?, 'Middle', 'JOD', 'Asia/Amman', 'completed')
     ON DUPLICATE KEY UPDATE
       expected_monthly_income = VALUES(expected_monthly_income),
       payment_day = VALUES(payment_day),
       detected_tier = VALUES(detected_tier),
       currency = VALUES(currency),
       timezone = VALUES(timezone),
       onboarding_status = VALUES(onboarding_status)`,
    [userId, DEMO.income, DEMO.paymentDay]
  );

  await conn.execute(
    `INSERT INTO allocation_preferences
       (user_id, needs_bps, wants_bps, savings_bps, source, based_on_income)
     VALUES (?, ?, ?, ?, 'system_tier', ?)
     ON DUPLICATE KEY UPDATE
       needs_bps = VALUES(needs_bps),
       wants_bps = VALUES(wants_bps),
       savings_bps = VALUES(savings_bps),
       source = VALUES(source),
       based_on_income = VALUES(based_on_income)`,
    [userId, DEMO.needsBps, DEMO.wantsBps, DEMO.savingsBps, DEMO.income]
  );

  const [ef] = await conn.execute(
    `SELECT id FROM goals
     WHERE user_id = ? AND goal_type = 'emergency_fund' AND is_system_managed = TRUE
     LIMIT 1`,
    [userId]
  );
  if (ef.length === 0) {
    await conn.execute(
      `INSERT INTO goals
         (user_id, name, target_amount, current_balance, status, goal_type, is_system_managed)
       VALUES (?, 'Emergency Fund', 2400, 80, 'active', 'emergency_fund', TRUE)`,
      [userId]
    );
  }

  const [laptop] = await conn.execute(
    `SELECT id FROM goals WHERE user_id = ? AND name = 'Demo Laptop' LIMIT 1`,
    [userId]
  );
  let goalId;
  if (laptop.length === 0) {
    const [gRes] = await conn.execute(
      `INSERT INTO goals
         (user_id, name, target_amount, current_balance, status, goal_type, is_system_managed, planned_contribution)
       VALUES (?, 'Demo Laptop', 500, 120, 'active', 'laptop', FALSE, 50)`,
      [userId]
    );
    goalId = gRes.insertId;
  } else {
    goalId = laptop[0].id;
  }

  return { userId, goalId };
}

async function ensureOpenCycle(userId) {
  try {
    const result = await CycleService.createCycle(userId, {
      idempotencyKey: `demo-cycle-${userId}`,
    });
    console.log('Created open cycle:', result?.cycle?.id);
    return result?.cycle?.id || null;
  } catch (err) {
    if (err.code === 'CYCLE_ALREADY_OPEN') {
      console.log('Open cycle already exists — reusing it');
      return null;
    }
    throw err;
  }
}

async function seedSampleActivity(conn, userId, goalId) {
  const [cycles] = await conn.execute(
    `SELECT id FROM financial_cycles WHERE user_id = ? AND status = 'open' ORDER BY id DESC LIMIT 1`,
    [userId]
  );
  if (cycles.length === 0) {
    console.warn('No open cycle — skipping sample transactions');
    return;
  }
  const cycleId = cycles[0].id;

  const [existingTx] = await conn.execute(
    `SELECT id FROM transactions WHERE user_id = ? AND cycle_id = ? AND description = 'Demo salary' LIMIT 1`,
    [userId, cycleId]
  );
  if (existingTx.length > 0) {
    console.log('Sample transactions already present');
    return;
  }

  await conn.execute(
    `INSERT INTO transactions
       (user_id, cycle_id, amount, direction, transaction_type, budget_bucket, income_kind,
        category, description, status, occurred_at, confirmed_at)
     VALUES
       (?, ?, 800, 'inflow', 'income', NULL, 'recurring', NULL, 'Demo salary', 'confirmed', NOW(), NOW()),
       (?, ?, 45, 'outflow', 'expense', 'needs', NULL, 'groceries', 'Demo groceries', 'confirmed', NOW(), NOW()),
       (?, ?, 25, 'outflow', 'expense', 'wants', NULL, 'coffee', 'Demo cafe', 'confirmed', NOW(), NOW())`,
    [userId, cycleId, userId, cycleId, userId, cycleId]
  );

  await conn.execute(
    `INSERT INTO goal_transactions
       (user_id, goal_id, cycle_id, amount, transaction_type, description, source_type)
     VALUES (?, ?, ?, 50, 'contribution', 'Demo contribution', 'user_contribution')`,
    [userId, goalId, cycleId]
  );

  console.log(`Seeded sample activity on cycle ${cycleId}`);
}

async function main() {
  const conn = await db.getConnection();
  try {
    const { userId, goalId } = await upsertDemoUser(conn);
    await ensureOpenCycle(userId);
    await seedSampleActivity(conn, userId, goalId);

    console.log('\n=========================================');
    console.log('Demo account ready');
    console.log(`  Phone (app field): ${DEMO.phoneLocal}`);
    console.log(`  Password:          ${DEMO.password}`);
    console.log('=========================================\n');
  } finally {
    conn.release();
    await db.end();
  }
}

main().catch((err) => {
  console.error('Demo seed failed:', err.message || err);
  process.exit(1);
});
