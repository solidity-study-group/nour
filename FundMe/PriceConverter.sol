// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import { AggregatorV3Interface } from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter{

    function getPrice() internal view returns(uint256){
        // whenever we want to interact with another contract we use : 
        // address : 0x694AA1769357215DE4FAC081bf1f309aDC325306
        // ABI using interface AggregatorV3Interface

        AggregatorV3Interface priceFeed = AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        (,int256 price,,,) = priceFeed.latestRoundData();
        // price of ETH in terms of USD 
        // to get the price in USD with . : 20000.0000000000
        return uint256(price * 1e10);

    }

    function getConversionRate(uint256 ethAmount) internal view returns(uint256) {
        //1ETH? = 
        uint256 ethPrice = getPrice(); // = 2000_00000000000000000
        uint256 ethAmountInUSD = (ethPrice * ethAmount) / 1e18;
        // price * 1e10 = (2000_00000000000000000 * 1_000000000000000000)/ 1e18;
        return ethAmountInUSD; // 1ETH = 2000$
    }

  
}
