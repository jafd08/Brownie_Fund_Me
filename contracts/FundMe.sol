// SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe {
    using SafeMathChainlink for uint256;
    mapping(address => uint256) public addressToAmountFunded;
    AggregatorV3Interface public priceFeed;
    address[] public funders;
    address public owner;

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    // payable funct -> this funct is used to pay
    // wei = smallest unit of measure of ether
    function fund() public payable {
        // msg are keywords already defined on the contract, where sender is the address sending
        uint256 minimumUSD = 50 * 10**18; // $50 - first number, others is for wei
        require(
            getConversionRate(msg.value) >= minimumUSD,
            "You need to spend more ETH! ($5+)"
        );
        addressToAmountFunded[msg.sender] += msg.value; //create a key-value pair to this mapping
        // what the ETH -> USD conversion rate ?
        funders.push(msg.sender);
    }

    function getVersion() public view returns (uint256) {
        return priceFeed.version();
    }

    function getPrice() public view returns (uint256) {
        // AggregatorV3Interface priceFeed = AggregatorV3Interface(
        //     0x8A753747A1Fa494EC906cE90E9f37563A8AF630e
        // );
        (, int256 answer, , , ) = priceFeed.latestRoundData(); // parenthresis are variables we are getting but not using.. so they can be ignored
        return uint256(answer * 10000000000);
    }

    //1000000000
    function getConversionRate(uint256 ethAmount)
        public
        view
        returns (uint256)
    {
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
        // 2570389561200 => 0.000002570389561200 eth =  1000000000 gwei
    }

    function getEntranceFee() public view returns (uint256) {
        uint256 minimumUSD = 50 * 10**18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10**18;
        return (minimumUSD * precision) / price;
    }

    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Only Owner of this contract can perform this!!"
        );
        _; // this mean to continue running the next lines of code
    }

    function withdraw() public payable onlyOwner {
        // onlyOwner modifier will be checked when calling this function
        // modifier : used to change the behavior of a function in a declarative way
        msg.sender.transfer(address(this).balance);

        //after withdrawing all money from the funds, we must reset the money the funders sent us
        // that is why we create the array 'funders'

        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
    }
}
