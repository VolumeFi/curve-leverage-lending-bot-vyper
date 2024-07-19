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
    def liquidate_extended(user: address, min_x: uint256, frac: uint256, use_eth: bool, callbacker: address, callback_args: DynArray[uint256,5]): nonpayable
    def user_state(user: address) -> uint256[4]: view
    def health(user: address, full: bool) -> int256: view

interface WrappedEth:
    def withdraw(amount: uint256): nonpayable

interface ERC20:
    def balanceOf(_owner: address) -> uint256: view
    def approve(_spender: address, _value: uint256) -> bool: nonpayable
    def transfer(_to: address, _value: uint256) -> bool: nonpayable

FACTORY: immutable(address)
CONTROLLER: immutable(address)
COLLATERAL: immutable(address)
WETH: immutable(address)
OWNER: immutable(address)
STABLECOIN: immutable(address)

@external
@payable
def __init__(controller: address, weth: address, owner: address, collateral: address, stablecoin: address):
    FACTORY = msg.sender
    CONTROLLER = controller
    COLLATERAL = collateral
    WETH = weth
    OWNER = owner
    STABLECOIN = stablecoin

@external
def create_loan_extended(collateral_amount: uint256, debt: uint256, N: uint256, callbacker: address, callback_args: DynArray[uint256,5]):
    assert msg.sender == FACTORY, "not factory"
    if COLLATERAL == WETH:
        Controller(CONTROLLER).create_loan_extended(collateral_amount, debt, N, callbacker, callback_args, value=collateral_amount)
    else:
        assert ERC20(COLLATERAL).approve(CONTROLLER, collateral_amount, default_return_value=True), "Failed approve"
        Controller(CONTROLLER).create_loan_extended(collateral_amount, debt, N, callbacker, callback_args)

@internal
def _safe_transfer(_token: address, _to: address, _amount: uint256):
    assert ERC20(_token).transfer(_to, _amount, default_return_value=True), "Failed transfer"

@external
def repay_extended(callbacker: address, callback_args: DynArray[uint256,5]) -> (uint256, uint256):
    assert msg.sender == FACTORY, "Unauthorized"
    bal0: uint256 = ERC20(STABLECOIN).balanceOf(self)
    bal1: uint256 = ERC20(COLLATERAL).balanceOf(self)
    Controller(CONTROLLER).repay_extended(callbacker, callback_args)
    bal0 = unsafe_sub(ERC20(STABLECOIN).balanceOf(self), bal0)
    bal1 = unsafe_sub(ERC20(COLLATERAL).balanceOf(self), bal1)
    if bal0 > 0:
        self._safe_transfer(STABLECOIN, OWNER, bal0)
    if bal1 > 0:
        if COLLATERAL == WETH:
            WrappedEth(WETH).withdraw(bal1)
            send(OWNER, bal1)
        else:
            self._safe_transfer(COLLATERAL, OWNER, bal1)
    return bal0, bal1

@external
def liquidate_extended(min_x: uint256, callbacker: address, callback_args: DynArray[uint256,5]) -> (uint256, uint256):
    assert msg.sender == FACTORY, "Unauthorized"
    use_eth: bool = False
    if COLLATERAL == WETH:
        use_eth = True
    bal0: uint256 = ERC20(STABLECOIN).balanceOf(self)
    bal1: uint256 = ERC20(COLLATERAL).balanceOf(self)
    Controller(CONTROLLER).liquidate_extended(self, min_x, 10 ** 18, use_eth, callbacker, callback_args)
    bal0 = unsafe_sub(ERC20(STABLECOIN).balanceOf(self), bal0)
    bal1 = unsafe_sub(ERC20(COLLATERAL).balanceOf(self), bal1)
    if bal0 > 0:
        self._safe_transfer(STABLECOIN, OWNER, bal0)
    if bal1 > 0:
        if COLLATERAL == WETH:
            WrappedEth(WETH).withdraw(bal1)
            send(OWNER, bal1)
        else:
            self._safe_transfer(COLLATERAL, OWNER, bal1)
    return bal0, bal1

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
