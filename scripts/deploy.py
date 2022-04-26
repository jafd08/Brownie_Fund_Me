from brownie import FundMe, MockV3Aggregator, network, config
from scripts.helpful_scripts import (
    get_account,
    deploy_mocks,
    LOCAL_BLOCKCHAIN_ENVIRONMENTS,
)

# replacing imports with the actual code is known as "flattening", think we do on brownie-config.yaml
# to remove a added file to be commited: git rm --cached {file}
def deploy_fund_me():
    account = get_account()
    # pass the price feed address to our fundme contract

    # if we are on persisten netwo like rinkeby, use the associated address
    # otherwise, deploy mocks (fake code)
    print(f"The active network is {network.show_active()}")
    if network.show_active() not in LOCAL_BLOCKCHAIN_ENVIRONMENTS:
        # price_feed_addr = "0x8A753747A1Fa494EC906cE90E9f37563A8AF630e"
        price_feed_addr = config["networks"][network.show_active()][
            "eth_usd_price_feed"
        ]
        print(" price_feed_addr:", price_feed_addr)
    else:

        print(" Deploying Mocks....  ")
        deploy_mocks()
        price_feed_addr = MockV3Aggregator[-1].address

    fund_me = FundMe.deploy(
        price_feed_addr,
        {"from": account},
        publish_source=config["networks"][network.show_active()].get("verify"),
    )
    print(f"Contract deployed to: {fund_me.address}")
    return fund_me


def main():
    deploy_fund_me()
