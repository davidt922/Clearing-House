pragma solidity ^0.4.20;

/**
 * Add oraclize API
 */
 import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

/**
 * Allow Slice strings
 */
import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "CompensationChamber.sol";

contract VariationMargin is usingOraclize
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

      uint timeUntilFirstVMRevisionInSeconds;

      address compensationChamberAddress;

    function VariationMargin(uint _timeUntilFirstVMRevisionInSeconds) public
    {
        compensationChamberAddress = msg.sender;
        timeUntilFirstVMRevisionInSeconds = _timeUntilFirstVMRevisionInSeconds;
    }

    function computeVariationMargin()
    {
        if (firstQuery == true)
        {
            firstQuery = false;
            oraclize_query(timeUntilFirstVMRevisionInSeconds, "URL", "");
        }
        else
        {
            oraclize_query(1*day, "URL", "");
        }
    }

    function __callback(bytes32 myid, string result)
    {
       CompensationChamber _compensationChamberObject = CompensationChamber(compensationChamberAddress);
       _compensationChamberObject.computeVariationMargin();
    }
}
