// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMeZKSync {
    address public immutable i_owner;
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;

    address[] public funders;
    mapping (address funder => uint256 amountFunded) public funderToAmountFunded;

    constructor() {
        i_owner = msg.sender; // Set the deployer as the owner
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert NotOwner();
        //require(msg.sender == i_owner, "Only the owner can call this function");
        _;
    }

    function fund() public payable {
        require(msg.value.getConversionRate() > MINIMUM_USD, "didnt send enough ether!");
        funders.push(msg.sender);
        funderToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner {
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++) {
            address funder = funders[funderIndex];
            funderToAmountFunded[funder] = 0;
        }
        funders =new address[](0);
        //transfer
        //payable(msg.sender).transfer(address(this).balance);
        
        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess, "Send failed!");
        
        //call
        (bool callSuccess,)= payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed!");
    }

    receive() external payable {
        fund();
    }
    
    fallback() external payable {
        fund();
    }
}