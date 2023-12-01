from ape import accounts, project, networks


def main():
    acct = accounts.load("deployer_account")
    blueprint = "0x13Ade234C76EAdE260bdFE174b2776c7C025B779"
    compass = "0xad34a6e42359d8DF482c2a30bDdDb99573CE4347"
    controller_factory = "0xC9332fdCB1C491Dcc683bAe86Fe3cb70360738BC"
    router = "0xF0d4c12A5768D806021F80a262B4d39d26C58b8D"
    refund_wallet = "0x6dc0A87638CD75Cc700cCdB226c7ab6C054bc70b"
    gas_fee = 15_000_000_000_000_000
    service_fee_collector = "0x7a16fF8270133F063aAb6C9977183D9e72835428"
    service_fee = 2_000_000_000_000_000
    max_base_fee = int(networks.active_provider.base_fee * 1.1)
    factory = project.factory.deploy(
        blueprint, compass, controller_factory, router, refund_wallet,
        gas_fee, service_fee_collector, service_fee, max_fee=max_base_fee,
        max_priority_fee=min(int(0.01e9), max_base_fee), sender=acct)

    print(factory)
