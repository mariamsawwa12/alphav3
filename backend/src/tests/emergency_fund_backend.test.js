// vitest globals
const { OnboardingService } = require('../services/onboarding.service');
const { CyclePlanningService } = require('../services/cycle-planning.service');
const { db } = require('../config/database');
describe('Emergency Fund Backend Logic', () => {
  let mockConn;

  beforeEach(() => {
    vi.clearAllMocks();
    mockConn = {
      beginTransaction: vi.fn(),
      commit: vi.fn(),
      rollback: vi.fn(),
      release: vi.fn(),
      execute: vi.fn()
    };
    vi.spyOn(db, 'getConnection').mockResolvedValue(mockConn);
    vi.spyOn(db, 'execute').mockImplementation(async (...args) => {
        return mockConn.execute(...args);
    });
  });

  describe('1. Onboarding EF Creation', () => {
    it('should create emergency fund with is_system_managed = TRUE', async () => {
      // Mock lockUserForOnboarding
      mockConn.execute.mockImplementation((query) => {
        if (query.includes('FROM users')) {
          return [[{ id: 1 }]];
        }
        if (query.includes('FROM goals WHERE')) {
          return [[]]; // No existing EF
        }
        if (query.includes('INSERT INTO goals')) {
          return [{ insertId: 100 }];
        }
        return [[]];
      });

      const result = await OnboardingService.saveFirstGoal(1, {
        goalType: 'emergency_fund',
        name: 'My EF',
        targetAmount: 1000,
        flexibility: 'flexible',
        plannedContribution: 100
      });

      expect(result.success).toBe(true);
      expect(result.goalId).toBe(100);
      
      const insertCall = mockConn.execute.mock.calls.find(call => call[0].includes('INSERT INTO goals'));
      expect(insertCall).toBeDefined();
      expect(insertCall[0]).toContain('is_system_managed');
      expect(insertCall[1]).toContain(true); // true was pushed to finalVals
    });

    it('should reject duplicate emergency fund for user', async () => {
      mockConn.execute.mockImplementation((query) => {
        if (query.includes('FROM users')) {
          return [[{ id: 1 }]];
        }
        if (query.includes('FROM goals WHERE')) {
          return [[{ id: 99 }]]; // Existing EF
        }
        return [[]];
      });

      await expect(OnboardingService.saveFirstGoal(1, {
        goalType: 'emergency_fund',
        name: 'My EF',
        targetAmount: 1000,
        flexibility: 'flexible',
        plannedContribution: 100
      })).rejects.toThrow('User already has an emergency fund');
    });
  });

  describe('Cycle Planning - Savings Allocation', () => {
    // We will test the linkSavingsAllocation logic here.
    it('should calculate emergencyFundAmount correctly (min of requested and capacity)', async () => {
      mockConn.execute.mockImplementation((query) => {
        if (query.includes('FROM financial_cycles')) { // cycle
          return [[{ id: 10, status: 'open' }]];
        }
        if (query.includes('FROM cycle_savings_allocations')) { // existing savings
          return [[]]; // null
        }
        if (query.includes('FROM cycle_allocation_snapshots')) { // snapshot
          return [[{ savings_target: 1000 }]];
        }
        if (query.includes('SUM(gca.planned_amount)')) { // goal allocations
          return [[{ total: 200 }]];
        }
        if (query.includes('FROM goals')) { // EF capacity
          return [[{ current_balance: 100, target_amount: 500 }]]; // remaining: 400
        }
        if (query.includes('INSERT INTO cycle_savings_allocations')) {
          return [{ insertId: 1 }];
        }
        return [[]];
      });

      // Requested EF: 10% of 1000 = 100. Remaining capacity = 400. So EF Amount = 100.
      const result = await CyclePlanningService.linkSavingsAllocation(1, 10, {
        emergencyFundPercentage: 10
      });

      expect(result.emergencyFundAmount).toBe(100);
      expect(result.unallocatedSavingsAmount).toBe(1000 - 100 - 200); // 700
      expect(result.emergencyFundTarget).toBe(500);
    });

    it('should throw if EF required but not found', async () => {
      mockConn.execute.mockImplementation((query) => {
        if (query.includes('FROM financial_cycles')) return [[{ id: 10, status: 'open' }]];
        if (query.includes('FROM cycle_savings_allocations')) return [[]];
        if (query.includes('FROM cycle_allocation_snapshots')) return [[{ savings_target: 1000 }]];
        if (query.includes('SUM(gca.planned_amount)')) return [[{ total: 200 }]];
        if (query.includes('FROM goals')) return [[]]; // NOT FOUND
        return [[]];
      });

      await expect(CyclePlanningService.linkSavingsAllocation(1, 10, {
        emergencyFundPercentage: 10
      })).rejects.toThrow('System managed emergency fund not found.');
    });

    it('should allow 0% EF without EF goal', async () => {
      mockConn.execute.mockImplementation((query) => {
        if (query.includes('FROM financial_cycles')) return [[{ id: 10, status: 'open' }]];
        if (query.includes('FROM cycle_savings_allocations')) return [[]];
        if (query.includes('FROM cycle_allocation_snapshots')) return [[{ savings_target: 1000 }]];
        if (query.includes('SUM(gca.planned_amount)')) return [[{ total: 200 }]];
        if (query.includes('FROM goals')) return [[]]; // NOT FOUND
        return [[]];
      });

      const result = await CyclePlanningService.linkSavingsAllocation(1, 10, {
        emergencyFundPercentage: 0
      });
      expect(result.emergencyFundAmount).toBe(0);
      expect(result.unallocatedSavingsAmount).toBe(800);
    });
  });

  describe('Cycle Planning - Update Savings Allocation', () => {
    it('should update allocation correctly', async () => {
      mockConn.execute.mockImplementation((query) => {
        if (query.includes('FROM financial_cycles')) return [[{ id: 10, status: 'open' }]];
        if (query.includes('FROM cycle_savings_allocations')) return [[{ id: 1 }]]; // EXISTS
        if (query.includes('FROM cycle_allocation_snapshots')) return [[{ savings_target: 1000 }]];
        if (query.includes('SUM(gca.planned_amount)')) return [[{ total: 200 }]];
        if (query.includes('FROM goals')) return [[{ current_balance: 100, target_amount: 500 }]];
        if (query.includes('UPDATE cycle_savings_allocations')) return [{ affectedRows: 1 }];
        return [[]];
      });

      const result = await CyclePlanningService.updateSavingsAllocation(1, 10, {
        emergencyFundPercentage: 20
      });

      expect(result.emergencyFundAmount).toBe(200); // 20% of 1000
      expect(result.unallocatedSavingsAmount).toBe(600); // 1000 - 200 - 200
    });
  });
});
