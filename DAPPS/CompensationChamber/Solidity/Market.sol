pragma solidity ^0.4.18;

/**
 * Add oraclize API
 */
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

/**
 * Allow Slice strings
 */
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract market
{
 address private marketAddress;

 constructor() public
 {
   marketAddress = msg.sender;
 }
}
