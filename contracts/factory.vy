#pragma version 0.3.10
#pragma optimize gas
#pragma evm-version shanghai
"""
@title Curve Leverage Bot Factory
@license Apache 2.0
@author Volume.finance
"""

interface ControllerFactory:
    def get_controller(collateral: address) -> address: view
    def WETH() -> address: view

interface ERC20:
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: nonpayable

interface WrappedEth:
    def withdraw(amount: uint256): nonpayable

interface Bot:
    def create_loan_extended(collateral_amount: uint256, debt: uint256, N: uint256, callbacker: address, callback_args: DynArray[uint256,5]): nonpayable
    def repay_extended(callbacker: address, callback_args: DynArray[uint256,5]): nonpayable
    def state() -> uint256[4]: view

event BotStarted:
    owner: address
    collateral: address
    collateral_amount: uint256
    debt: uint256
    N: uint256
    expire: uint256
    callbacker: address
    callback_args: DynArray[uint256, 5]

event UpdateBlueprint:
    old_blueprint: address
    new_blueprint: address

event UpdateCompass:
    old_compass: address
    new_compass: address

event UpdateRefundWallet:
    old_refund_wallet: address
    new_refund_wallet: address

event SetPaloma:
    paloma: bytes32

event UpdateGasFee:
    old_gas_fee: uint256
    new_gas_fee: uint256

event UpdateServiceFeeCollector:
    old_service_fee_collector: address
    new_service_fee_collector: address

event UpdateServiceFee:
    old_service_fee: uint256
    new_service_fee: uint256

MAX_SIZE: constant(uint256) = 8
DENOMINATOR: constant(uint256) = 10000
WETH: immutable(address)
CONTROLLER_FACTORY: immutable(address)
blueprint: public(address)
compass: public(address)
bot_to_owner: public(HashMap[address, address])
refund_wallet: public(address)
gas_fee: public(uint256)
service_fee_collector: public(address)
service_fee: public(uint256)
paloma: public(bytes32)

@external
def __init__(_blueprint: address, _compass: address, controller_factory: address, _refund_wallet: address, _gas_fee: uint256, _service_fee_collector: address, _service_fee: uint256):
    self.blueprint = _blueprint
    self.compass = _compass
    self.refund_wallet = _refund_wallet
    self.gas_fee = _gas_fee
    self.service_fee_collector = _service_fee_collector
    self.service_fee = _service_fee
    CONTROLLER_FACTORY = controller_factory
    WETH = ControllerFactory(controller_factory).WETH()
    log UpdateCompass(empty(address), _compass)
    log UpdateBlueprint(empty(address), _blueprint)
    log UpdateRefundWallet(empty(address), _refund_wallet)
    log UpdateGasFee(empty(uint256), _gas_fee)
    log UpdateServiceFeeCollector(empty(address), _service_fee_collector)
    log UpdateServiceFee(empty(uint256), _service_fee)

@external
@payable
@nonreentrant('lock')
def create_bot(collateral: address, collateral_amount: uint256, debt: uint256, N: uint256, callbacker: address, callback_args: DynArray[uint256,5], expire: uint256):
    _gas_fee: uint256 = self.gas_fee
    _service_fee: uint256 = self.service_fee
    controller: address = ControllerFactory(CONTROLLER_FACTORY).get_controller(collateral)
    bot: address = empty(address)
    _amount: uint256 = collateral_amount
    _service_fee_amount: uint256 = 0
    if _service_fee > 0:
        _service_fee_amount = unsafe_div(_amount * _service_fee, DENOMINATOR)
        _amount = unsafe_sub(_amount, _service_fee_amount)
    if collateral == WETH:
        expected_value: uint256 = collateral_amount + _gas_fee
        if msg.value > expected_value:
            send(msg.sender, unsafe_sub(msg.value, expected_value))
        elif msg.value < expected_value:
            if msg.value != _gas_fee:
                assert msg.value > _gas_fee, "insuf value"
                send(msg.sender, unsafe_sub(msg.value, _gas_fee))
            ERC20(WETH).transferFrom(msg.sender, self, collateral_amount)
            WrappedEth(WETH).withdraw(collateral_amount)
        send(self.service_fee_collector, _service_fee_amount)
        bot = create_from_blueprint(self.blueprint, controller, WETH, msg.sender, collateral, value=_amount, code_offset=3)
    else:
        if msg.value != _gas_fee:
            assert msg.value > _gas_fee, "insuf value"
            send(msg.sender, unsafe_sub(msg.value, _gas_fee))
        bot = create_from_blueprint(self.blueprint, controller, WETH, msg.sender, collateral, code_offset=3)
        assert ERC20(collateral).transferFrom(msg.sender, bot, _amount, default_return_value=True)
        if _service_fee_amount > 0:
            assert ERC20(collateral).transferFrom(msg.sender, self.service_fee_collector, _service_fee_amount, default_return_value=True)
    send(self.refund_wallet, _gas_fee)
    Bot(bot).create_loan_extended(collateral_amount, debt, N, callbacker, callback_args)
    self.bot_to_owner[bot] = msg.sender
    log BotStarted(msg.sender, collateral, collateral_amount, debt, N, expire, callbacker, callback_args)

@external
@nonreentrant('lock')
def repay_bot(bot: address, callbacker: address, callback_args: DynArray[uint256,5]):
    _len: uint256 = unsafe_add(unsafe_mul(unsafe_add(len(callback_args), 5), 32), 4)
    assert msg.sender == self.compass and len(msg.data) == _len and convert(slice(msg.data, unsafe_sub(_len, 32), 32), bytes32) == self.paloma, "Unauthorized"
    Bot(bot).repay_extended(callbacker, callback_args)

@external
@view
def state(bot: address) -> uint256[4]:
    return Bot(bot).state()

@external
def update_compass(new_compass: address):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    self.compass = new_compass
    log UpdateCompass(msg.sender, new_compass)

@external
def update_blueprint(new_blueprint: address):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_blueprint:address = self.blueprint
    self.blueprint = new_blueprint
    log UpdateCompass(old_blueprint, new_blueprint)

@external
def set_paloma():
    assert msg.sender == self.compass and self.paloma == empty(bytes32) and len(msg.data) == 36, "Invalid"
    _paloma: bytes32 = convert(slice(msg.data, 4, 32), bytes32)
    self.paloma = _paloma
    log SetPaloma(_paloma)

@external
def update_refund_wallet(new_refund_wallet: address):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_refund_wallet: address = self.refund_wallet
    self.refund_wallet = new_refund_wallet
    log UpdateRefundWallet(old_refund_wallet, new_refund_wallet)

@external
def update_gas_fee(new_gas_fee: uint256):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_gas_fee: uint256 = self.gas_fee
    self.gas_fee = new_gas_fee
    log UpdateGasFee(old_gas_fee, new_gas_fee)

@external
def update_service_fee_collector(new_service_fee_collector: address):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_service_fee_collector: address = self.service_fee_collector
    self.service_fee_collector = new_service_fee_collector
    log UpdateServiceFeeCollector(old_service_fee_collector, new_service_fee_collector)

@external
def update_service_fee(new_service_fee: uint256):
    assert msg.sender == self.compass and len(msg.data) == 68 and convert(slice(msg.data, 36, 32), bytes32) == self.paloma, "Unauthorized"
    old_service_fee: uint256 = self.service_fee
    self.service_fee = new_service_fee
    log UpdateServiceFee(old_service_fee, new_service_fee)


@external
@payable
def __default__():
    pass