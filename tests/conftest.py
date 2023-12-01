#!/usr/bin/python3

import pytest
from typing import Union


@pytest.fixture(scope="session")
def Deployer(accounts):
    return accounts[0]


@pytest.fixture(scope="session")
def Alice(accounts):
    return accounts[1]


@pytest.fixture(scope="session")
def Bob(accounts):
    return accounts[2]


@pytest.fixture(scope="session")
def RefundWallet(accounts):
    return accounts[3]


@pytest.fixture(scope="session")
def ServiceFeeCollector(accounts):
    return accounts[4]


@pytest.fixture(scope="session")
def Compass(accounts):
    return accounts[5]


@pytest.fixture(scope="session")
def CurveRouter(project):
    return project.curve_router.at(
        "0xF0d4c12A5768D806021F80a262B4d39d26C58b8D")


@pytest.fixture(scope="session")
def WETH(project):
    return project.weth.at("0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2")


@pytest.fixture(scope="session")
def USDC(project):
    return project.usdc.at("0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48")


@pytest.fixture(scope="session")
def UniswapV3Router(project):
    return project.uniswap_v3_router.at(
        "0xE592427A0AEce92De3Edee1F18E0157C05861564")


@pytest.fixture(scope="session")
def BotBlueprint(Deployer, project):
    initcode = get_blueprint_initcode(
        project.curve_leverage_bot.contract_type.deployment_bytecode.bytecode)
    tx = project.provider.network.ecosystem.create_transaction(
        chain_id=project.provider.chain_id,
        data=initcode
    )
    receipt = Deployer.call(tx)
    return receipt


@pytest.fixture(scope="session")
def LeverageBotFactory(
        BotBlueprint, Compass, CurveRouter, RefundWallet,
        ServiceFeeCollector, Deployer, project):
    controller_factory = "0xC9332fdCB1C491Dcc683bAe86Fe3cb70360738BC"
    gas_fee = 15000000000000000  # 0.015ETH
    service_fee = 2000000000000000  # 0.2%
    return Deployer.deploy(
        project.factory, BotBlueprint.contract_address, Compass,
        controller_factory, CurveRouter, RefundWallet, gas_fee,
        ServiceFeeCollector, service_fee)


def get_blueprint_initcode(initcode: Union[str, bytes]):
    if isinstance(initcode, str):
        initcode = bytes.fromhex(initcode[2:])
    initcode = b"\xfe\x71\x00" + initcode
    initcode = (
        b"\x61" + len(initcode).to_bytes(2, "big") +
        b"\x3d\x81\x60\x0a\x3d\x39\xf3" + initcode
    )
    return initcode
