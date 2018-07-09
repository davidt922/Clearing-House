pragma solidity ^0.4.20;

/**
 * Add oraclize API
 */
 import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

/**
 * Allow Slice strings
 */
import "github.com/Arachnid/solidity-stringutils/strings.sol";

contract variationMargin is usingOraclize
{
      /**
       * To enable strings.sol library
       */
      using strings for *;

     /**
      * Number os seconds in 24 h
      */
      uint private dayInSeconds = 86400;

      bool firstQuery = true;

      uint timeUntilFirstVMRevisionInSeconds = _timeUntilFirstVMRevisionInSeconds;

      address compensationChamberAddress;

    function variationMargin(uint _timeUntilFirstVMRevisionInSeconds) public
    {
        compensationChamberAddress = msg.sender;
    }

    function computeVariationMargin()
    {
        if (firstQuery == true)
        {
            firstQuery = false;
            oraclize_query(timeUntilFirstVMRevisionInSeconds, "URL", "");
        }
    }

    function __callback(bytes32 myid, string result)
    {
       CompensationChamber _compensationChamberObject = CompensationChamber(compensationChamberAddress);
    }
}
