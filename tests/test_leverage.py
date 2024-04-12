#!/usr/bin/python3

from conftest import function_signature, encode, bstring2bytes32, set_paloma
import ape


def test_set_paloma(project, LeverageBotFactory, Alice, Compass):
    with ape.reverts():
        LeverageBotFactory.set_paloma(sender=Alice)
    with ape.reverts():
        LeverageBotFactory.set_paloma(sender=Compass)
    set_paloma(project, LeverageBotFactory, Compass)


def test_deposit(project, LeverageBotFactory, UniswapV3Router, WBTC, WETH, Alice, Compass):
    set_paloma(project, LeverageBotFactory, Compass)
    UniswapV3Router.exactInputSingle(
        [WETH, WBTC, 3000, Alice, 2 ** 32, 10 ** 18, 2 * 10 ** 4, 0],
        sender=Alice,
        value=10 ** 18)
    WBTC.approve(LeverageBotFactory, 2 * 10 ** 4, sender=Alice)
    swap_infos = [[
        [
          '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
        ],
        [
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
          [0, 0, 0, 0, 0],
        ],
        20000,
        20000,
        [
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
          '0x0000000000000000000000000000000000000000',
        ]]]
    collateral = '0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599'
    debt = 30000000000000000000
    N = 10
    callbacker = '0xa2518b71ee64e910741f5cf480b19e8e402de4d7'
    callback_args = [1, 10000]
    leverage = 624
    deleverage_percentage = 100
    health_threshold = 206
    expire = 33241352537
    number_trades = 2
    interval = 30
    LeverageBotFactory.create_bot(swap_infos, collateral, debt, N, callbacker, callback_args, leverage, deleverage_percentage, health_threshold, expire, number_trades, interval, sender=Alice, value=5 * 10 ** 16)
    deposit_id = 0
    callbacker = '0xa2518b71ee64e910741f5cf480b19e8e402de4d7'
    callback_args = [1, 10000]
    remaining_count = 1
    data = function_signature("create_next_bot(uint256,address,uint256[],uint256)") + encode(["uint256", "address", "uint256[]", "uint256"], [deposit_id, callbacker, callback_args, remaining_count]) + bstring2bytes32(b"paloma")
    tx = project.provider.network.ecosystem.create_transaction(chain_id=project.provider.chain_id, to=LeverageBotFactory.address, data=data)
    Compass.call(tx)


