from ape import accounts, project, networks


def main():
    acct = accounts.load("deployer_account")
    blueprint = "0x10cD32b433e77Ac75206897101267656BbEd4eA7"
    compass = "0xB01cC20Fe02723d43822819ec57fCbadf31f1537"
    controller_factory = "0xC9332fdCB1C491Dcc683bAe86Fe3cb70360738BC"
    router = "0xF0d4c12A5768D806021F80a262B4d39d26C58b8D"
    refund_wallet = "0x6dc0A87638CD75Cc700cCdB226c7ab6C054bc70b"
    gas_fee = 15_000_000_000_000_000
    service_fee_collector = "0x7a16fF8270133F063aAb6C9977183D9e72835428"
    service_fee = 2_000_000_000_000_000
    priority_fee = int(networks.active_provider.priority_fee)
    base_fee = int(networks.active_provider.base_fee + priority_fee)
    factory = project.factory.deploy(
        blueprint, compass, controller_factory, router, refund_wallet,
        gas_fee, service_fee_collector, service_fee, max_fee=base_fee,
        max_priority_fee=priority_fee, sender=acct)

    print(factory)
