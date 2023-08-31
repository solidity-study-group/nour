// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { AggregatorV3Interface } from "@chainlink/contracts/v0.8/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

// get funds from users
// withdraw funds
// set a minimum funding value in USD 

contract FundMe {

    using PriceConverter for uint256;

    error NotOwner(); // better then require statement 
    uint256 public constant MINIMUM_USD = 5e18; // constant and immutable for more gas optimization 
    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public immutable i_owner;
    constructor(){
        i_owner = msg.sender;
    }
    
    function fund() public payable {
        // allow users to send money
        // have a minimum money sent 
        // how to send ETH to this contract ? by mark the function payable
        // What is a revert ? undo any actions that have been done, and send the remaining gas back

        //require(getConversionRate(msg.value) >= minimumUsd, "didn't send enough ETH"); // 1e18 = 1 ETH = 1000000000000000000 wei = 1 * 10 ** 18
        require(msg.value.getConversionRate() >= MINIMUM_USD, "didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;

    }

      function getVersion() public view returns (uint256){
        return AggregatorV3Interface(0x694AA1769357215DE4FAC081bf1f309aDC325306).version();
    }

    function withdraw() public OnlyOwner {
        // use for loop to withdraw all funds of funders array:
        for (uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) 
        {
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;

            // reset the array:
            funders = new address[](0);
            //withdraw the funds:
            //method 1. transfer : if it fails, it'll return an error and revert the Tx
            //payable(msg.sender).transfer(address(this).balance); // payable( msg.sender) : it's a payable address
            
            // method 2. send : it'll return a boolean of whether or not it was successfull
            //bool sendSuccess = payable(msg.sender).send(address(this).balance);
            //require(sendSuccess, "call failed");


            // method 3. call : it forwards all gas, so it doesn't have a capped gas and also it returns a boolean 
             (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
             require(callSuccess, "call failed");

        }
     }

    modifier OnlyOwner(){
         //require(msg.sender == i_owner,"Sender is not owner!");
         if(msg.sender != i_owner){
             revert NotOwner();
         }
         _;
    }
 

    fallback() external payable {
        fund();
    }

    receive() external payable {
        fund();
    }

}