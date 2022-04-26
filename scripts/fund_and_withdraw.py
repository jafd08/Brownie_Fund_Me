from brownie import FundMe
from scripts.helpful_scripts import get_account


def fund():
    acc = get_account()
    fund_me = FundMe[-1]
    entrance_fee = fund_me.getEntranceFee()
    print("The current entry_fee is:", entrance_fee)
    print(" Funding... ")
    fund_me.fund({"from": acc, "value": entrance_fee})


def withdraw():
    fund_me = FundMe[-1]
    acc = get_account()
    fund_me.withdraw({"from": acc})


def main():
    fund()
    withdraw()
