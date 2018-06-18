pragma solidity ^0.4.18;

contract market
{
 address private marketAddress;

 constructor() public
 {
   marketAddress = msg.sender;
 }
}
