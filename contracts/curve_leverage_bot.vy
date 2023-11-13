#pragma version 0.3.10
#pragma optimize gas
#pragma evm-version shanghai
"""
@title Curve Leverage Bot
@license Apache 2.0
@author Volume.finance
"""

interface Controller:
    def create_loan_extended(collateral: uint256, debt: uint256, N: uint256, callbacker: address, callback_args: DynArray[uint256,5]): payable
    def repay_extended(callbacker: address, callback_args: DynArray[uint256,5]): nonpayable
    def user_state(user: address) -> uint256[4]: view
    def health(user: address, full: bool) -> int256: view

interface ERC20:
    def balanceOf(_owner: address) -> uint256: view
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable

FACTORY: immutable(address)
CONTROLLER: immutable(address)
COLLATERAL: immutable(address)
WETH: immutable(address)
OWNER: immutable(address)

@external
@payable
def __init__(controller: address, weth: address, owner: address, collateral: address):
    FACTORY = msg.sender
    CONTROLLER = controller
    COLLATERAL = collateral
    WETH = weth
    OWNER = owner

@external
def create_loan_extended(collateral_amount: uint256, debt: uint256, N: uint256, callbacker: address, callback_args: DynArray[uint256,5]):
    assert msg.sender == FACTORY, "not factory"
    if COLLATERAL == WETH:
        Controller(CONTROLLER).create_loan_extended(collateral_amount, debt, N, callbacker, callback_args, value=collateral_amount)
    else:
        assert ERC20(COLLATERAL).approve(CONTROLLER, collateral_amount, default_return_value=True)
        Controller(CONTROLLER).create_loan_extended(collateral_amount, debt, N, callbacker, callback_args)

@external
def repay_extended(callbacker: address, callback_args: DynArray[uint256,5]) -> uint256:
    assert msg.sender == FACTORY, "not factory"
    if COLLATERAL == WETH:
        old_balance: uint256 = self.balance
        Controller(CONTROLLER).repay_extended(callbacker, callback_args)
        bal: uint256 = self.balance
        assert bal > old_balance, "full repay failed"
        send(OWNER, bal)
        return bal
    else:
        old_balance: uint256 = ERC20(COLLATERAL).balanceOf(self)
        Controller(CONTROLLER).repay_extended(callbacker, callback_args)
        bal: uint256 = ERC20(COLLATERAL).balanceOf(self)
        assert bal > old_balance, "full repay failed"
        assert ERC20(COLLATERAL).transfer(OWNER, bal, default_return_value=True)
        return bal

@external
@view
def state() -> uint256[4]:
    return Controller(CONTROLLER).user_state(self)

@external
@view
def health() -> int256:
    return Controller(CONTROLLER).health(self, True)

@external
@payable
def __default__():
    pass
