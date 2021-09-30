// SPDX-License-Identifier: MIT
pragma solidity ^0.6.6;

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

contract FundMe{
    
    mapping(address=>uint256) public addressToAmountFunded;
    using SafeMathChainlink for uint256;
    address public owner;
    address[] public funders;
    AggregatorV3Interface public priceFeed;
    
    constructor(address _priceFeed)public{
        owner = msg.sender;
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
    function fund() public payable {
        uint256 minimumUSD = 50 * 10 ** 18;
        require(getConversionRate(msg.value) >= minimumUSD, "You need to send more ETH");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
   
    }
    
    function getFeeds() public view returns(uint256){
        // AggregatorV3Interface prices = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        return priceFeed.version();
    }
    
    function getPrice() public view returns(uint256){
        //   AggregatorV3Interface priceFeed = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        (,int256 answer,,,) = priceFeed.latestRoundData();
        return uint256(answer * 10000000000);
    }
    
    function getConversionRate(uint256 ethAmount) public view returns(uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1000000000000000000;
        return ethAmountInUsd;
        
    }

    function getEntranceFee() public view returns (uint256)
    {
        uint256 minimumUSD = 50 * 10 ** 18;
        uint256 price = getPrice();
        uint256 precision = 1 * 10 ** 18;
        return (minimumUSD * precision) / price;

   }
    
    modifier onlyOwner{
        require(msg.sender == owner);
        _;
    }
    
    function withdraw() payable onlyOwner public{
        msg.sender.transfer(address(this).balance);
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        
        funders = new address[](0);
    }

}