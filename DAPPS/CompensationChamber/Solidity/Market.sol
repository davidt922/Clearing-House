pragma solidity ^0.4.18;

/**
 * Add oraclize API
 */
import "./lib/oraclizeAPI.sol";

/**
 * Allow Slice strings
 */
import "./lib/strings.sol";

contract market
{
 address private marketAddress;

 constructor() public
 {
   marketAddress = msg.sender;
 }
}
