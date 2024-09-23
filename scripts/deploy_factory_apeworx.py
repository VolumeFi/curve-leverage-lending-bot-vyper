from ape import accounts, project, networks


def main():
    acct = accounts.load("deployer_account")
    blueprint = "0x905D8b19d4C78A4Fa76B9868F01bDCB52133745F"
    compass = "0xDcBd07EEC1D48aE0A14E61dD09BB5AA9c7ed391d"
    controller_factory = "0xC9332fdCB1C491Dcc683bAe86Fe3cb70360738BC"
    router = "0xF0d4c12A5768D806021F80a262B4d39d26C58b8D"
    refund_wallet = "0x6dc0A87638CD75Cc700cCdB226c7ab6C054bc70b"
    gas_fee = 40_000_000_000_000_000
    service_fee_collector = "0xe693603C9441f0e645Af6A5898b76a60dbf757F4"
    service_fee = 0
    priority_fee = int(0.01e9)
    base_fee = int(networks.active_provider.base_fee * 1.2 + priority_fee)
    factory = project.factory.deploy(
        blueprint, compass, controller_factory, router, refund_wallet,
        gas_fee, service_fee_collector, service_fee, max_fee=base_fee,
        max_priority_fee=priority_fee, sender=acct)

    print(factory)
