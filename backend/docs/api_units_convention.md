# API Units Convention

## Currency and Money Amounts
- All monetary amounts in the database and API represent the **Jordanian Dinar (JOD)** directly as integers.
- **Value 1** = **1 JOD**
- **Value 50** = **50 JOD**
- **DO NOT** divide or multiply by 100 or 1000 on the client side. The amounts are NOT in minor units (fils/piasters) at the moment.
- The system currently uses `BIGINT` and `Math.round()` in backend, meaning it only fully supports whole JOD integers in this phase.
- Supporting fractional values (like `DECIMAL(15,3)`) would be a separate schema and logic migration. 

## Percentages and BPS
- **emergencyFundPercentage**: Represented as a percentage value from **0 to 100**. For example, `10` means 10%.
- **BPS (Basis Points)**: Used for allocations (`needs_bps`, `wants_bps`, `savings_bps`). Represented as integers from **0 to 10000**.
  - `10000` = 100%
  - `5000` = 50%
  - `100` = 1%

## Known Issues
- Currently, the Flutter client divides amounts by 100 in `savings_allocation_screen.dart` (due to an assumption that the units were in base minor units). This should be corrected in future frontend updates to align with this convention.
