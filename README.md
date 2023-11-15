# Curve Leverage Lending Bot

## factory.vy

### create_bot

This function deploys a bot contract using blueprint and create a loan.

| Key           | Type       | Description                                                       |
| ------------- | ---------- | ----------------------------------------------------------------- |
| swap_infos    | SwapInfo[] | swap info array to swap tokens on Curve                           |
| collateral    | address    | collateral token address                                          |
| debt          | uint256    | crvUSD amount to lend more from the Curve pool                    |
| N             | uint256    | number of bands the deposit is made into of Curve pool            |
| callbacker    | address    | address of the callback contract                                  |
| callback_args | uint256[]  | extra arguments for the callback (up to 5) such as min_amount etc |
| expire        | uint256    | expire timestamp of the bot                                       |

### repay_bot

This function adds collateral to prevent liquidation. This function is called by Compass-EVM only.

| Key           | Type        | Description                                                             |
| ------------- | ----------- | ----------------------------------------------------------------------- |
| bots          | address[]   | bots address array                                                      |
| callbackers   | address[]   | callback contract address array                                         |
| callback_args | uint256[][] | extra arguments array for the callback (up to 5) such as min_amount etc |

### health

This function returns health value. This is a view function.

| Key        | Type    | Description                  |
| ---------- | ------- | ---------------------------- |
| collateral | address | collateral token address     |
| bot        | address | bot address                  |
| **Return** | int256  | Returns health of collateral |

### state

This function returns loan state. This is a view function.

| Key        | Type       | Description                       |
| ---------- | ---------- | --------------------------------- |
| collateral | address    | collateral token address          |
| bot        | address    | bot address                       |
| **Return** | uint256[4] | [collateral, stablecoin, debt, N] |

### update_compass

Update Compass-EVM address.  This is run by Compass-EVM only.

| Key         | Type    | Description             |
| ----------- | ------- | ----------------------- |
| new_compass | address | New compass-evm address |

### update_refund_wallet

Update gas refund wallet address.  This is run by Compass-EVM only.

| Key               | Type    | Description               |
| ----------------- | ------- | ------------------------- |
| new_refund_wallet | address | New refund wallet address |

### update_fee

Update gas fee amount to pay.  This is run by Compass-EVM only.

| Key     | Type    | Description    |
| ------- | ------- | -------------- |
| new_fee | uint256 | New fee amount |

### set_paloma

Set Paloma CW address in bytes32.  This is run by Compass-EVM only and after setting paloma, the bot can start working.

| Key | Type | Description |
| --- | ---- | ----------- |
| -   | -    | -           |

### update_service_fee_collector

Update service fee collector address.  This is run by the original fee collector address. The address receives service fee from swapping.

| Key                       | Type    | Description                       |
| ------------------------- | ------- | --------------------------------- |
| new_service_fee_collector | address | New service fee collector address |


## curve_lending_bot.vy

### create_loan_extended

This function creates a loan. Only run by a factory contract.

| Key           | Type       | Description                                                       |
| ------------- | ---------- | ----------------------------------------------------------------- |
| collateral_amount    | address    | collateral token address                                          |
| debt          | uint256    | crvUSD amount to lend more from the Curve pool                    |
| N             | uint256    | number of bands the deposit is made into of Curve pool            |
| callbacker    | address    | address of the callback contract                                  |
| callback_args | uint256[]  | extra arguments for the callback (up to 5) such as min_amount etc |

### repay_extended

This function creates a loan. Only run by a factory contract.

| Key           | Type       | Description                                                       |
| ------------- | ---------- | ----------------------------------------------------------------- |
| callbacker    | address    | address of the callback contract                                  |
| callback_args | uint256[]  | extra arguments for the callback (up to 5) such as min_amount etc |

### state

This function returns loan state. This is a view function.

| Key        | Type       | Description                       |
| ---------- | ---------- | --------------------------------- |
| **Return** | uint256[4] | [collateral, stablecoin, debt, N] |

### health

This function returns health value. This is a view function.

| Key        | Type    | Description                  |
| ---------- | ------- | ---------------------------- |
| **Return** | int256  | Returns health of collateral |
