# Curve Leverage Lending Bot

This project implements a smart contract system for a Curve Leverage Lending Bot, designed to interact with Curve Finance's liquidity pools. It includes various functionalities such as creating and repaying loans, querying the state and health of loans, and managing operational settings. The contracts are written in Vyper.

## Factory Contract (`factory.vy`)

### Functions

#### `create_bot`
Creates a new bot with specified parameters.

- **Parameters:**
  - `swap_infos` (DynArray[SwapInfo, MAX_SIZE]): Array of SwapInfo to define the swap strategy.
  - `collateral` (address): Address of the collateral token.
  - `debt` (uint256): Amount of crvUSD to be borrowed.
  - `N` (uint256): Number of bands for the Curve pool deposit.
  - `callbacker` (address): Address of the callback contract.
  - `callback_args` (DynArray[uint256,5]): Additional arguments for the callback.
  - `expire` (uint256): Expiration timestamp of the bot.

#### `repay_bot`
Repays the bot to prevent liquidation.

- **Parameters:**
  - `bots` (DynArray[address, MAX_SIZE]): Array of bot addresses.
  - `callbackers` (DynArray[address, MAX_SIZE]): Array of callback contract addresses.
  - `callback_args` (DynArray[DynArray[uint256,5], MAX_SIZE]): Array of additional arguments for the callback.

#### `state`
Returns the state of a specified bot.

- **Parameters:**
  - `bot` (address): Address of the bot.
- **Returns:** `uint256[4]`: Array containing collateral, stablecoin, debt, and N.

#### `health`
Returns the health value of a specified bot's collateral.

- **Parameters:**
  - `bot` (address): Address of the bot.
- **Returns:** `int256`: Health of the collateral.

#### `update_compass`
Updates the Compass-EVM address.

- **Parameters:**
  - `new_compass` (address): New Compass-EVM address.

#### `update_refund_wallet`
Updates the gas refund wallet address.

- **Parameters:**
  - `new_refund_wallet` (address): New refund wallet address.

#### `update_gas_fee`
Updates the gas fee amount.

- **Parameters:**
  - `new_gas_fee` (uint256): New fee amount.

#### `set_paloma`
Sets the Paloma CW address.

#### `update_service_fee_collector`
Updates the service fee collector address.

- **Parameters:**
  - `new_service_fee_collector` (address): New service fee collector address.

## Curve Lending Bot (`curve_lending_bot.vy`)

### Functions

#### `create_loan_extended`
Creates a loan.

- **Parameters:**
  - `collateral_amount` (uint256): Amount of collateral token.
  - `debt` (uint256): Amount of crvUSD to be borrowed.
  - `N` (uint256): Number of bands for the Curve pool deposit.
  - `callbacker` (address): Address of the callback contract.
  - `callback_args` (DynArray[uint256,5]): Additional arguments for the callback.

#### `repay_extended`
Repays a loan.

- **Parameters:**
  - `callbacker` (address): Address of the callback contract.
  - `callback_args` (DynArray[uint256,5]): Additional arguments for the callback.

The other functions (`state`, `health`) remain the same as in the factory contract.


## Events

### `BotStarted`
Emitted when a new bot is created.
- **Properties:**
  - `owner` (address): The address of the bot owner.
  - `bot` (address): The address of the created bot.
  - `collateral` (address): The address of the collateral token.
  - `collateral_amount` (uint256): The amount of collateral token.
  - `debt` (uint256): The amount of crvUSD borrowed.
  - `N` (uint256): The number of bands for the Curve pool deposit.
  - `expire` (uint256): The expiration timestamp of the bot.
  - `callbacker` (address): The address of the callback contract.
  - `callback_args` (DynArray[uint256, 5]): The additional arguments for the callback.

### `BotRepayed`
Emitted when a bot is repaid.
- **Properties:**
  - `owner` (address): The address of the bot owner.
  - `bot` (address): The address of the repaid bot.
  - `return_amount` (uint256): The amount returned in the repayment.

### `UpdateBlueprint`
Emitted when the blueprint is updated.
- **Properties:**
  - `old_blueprint` (address): The address of the old blueprint.
  - `new_blueprint` (address): The address of the new blueprint.

### `UpdateCompass`
Emitted when the Compass-EVM address is updated.
- **Properties:**
  - `old_compass` (address): The old Compass-EVM address.
  - `new_compass` (address): The new Compass-EVM address.

### `UpdateRefundWallet`
Emitted when the refund wallet is updated.
- **Properties:**
  - `old_refund_wallet` (address): The old refund wallet address.
  - `new_refund_wallet` (address): The new refund wallet address.

### `SetPaloma`
Emitted when the Paloma CW address is set.
- **Properties:**
  - `paloma` (bytes32): The Paloma CW address.

### `UpdateGasFee`
Emitted when the gas fee is updated.
- **Properties:**
  - `old_gas_fee` (uint256): The old gas fee amount.
  - `new_gas_fee` (uint256): The new gas fee amount.

### `UpdateServiceFeeCollector`
Emitted when the service fee collector address is updated.
- **Properties:**
  - `old_service_fee_collector` (address): The old service fee collector address.
  - `new_service_fee_collector` (address): The new service fee collector address.

### `UpdateServiceFee`
Emitted when the service fee is updated.
- **Properties:**
  - `old_service_fee` (uint256): The old service fee amount.
  - `new_service_fee` (uint256): The new service fee amount.

These events provide detailed insights into the various actions and changes within the system, ensuring transparency and accountability.

