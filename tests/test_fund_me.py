from scripts.helpful_scripts import LOCAL_BLOCKCHAIN_ENVIRONMENTS, get_account
from scripts.deploy import deploy_fund_me
from brownie import network, accounts, exceptions
import pytest


def test_fund_me_withdraw():
    print(network.show_active())
    account = get_account()
    fund_me = deploy_fund_me();
    entry_fee = fund_me.getEntranceFee() + 100
    txn = fund_me.fund({"from": account, "value": entry_fee})
    txn.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == entry_fee
    txn2 = fund_me.withdraw({"from": account})
    txn2.wait(1)
    assert fund_me.addressToAmountFunded(account.address) == 0

def test_only_can_withdraw():
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        pytest.skip('only for local testing')
    fund_me = deploy_fund_me()
    bad_actor = accounts.add()
    with pytest.raises(exceptions.VirtualMachineError):
        fund_me.withdraw({"from": bad_actor})

        



def main():
    test_fund_me_withdraw()
    test_only_can_withdraw()    