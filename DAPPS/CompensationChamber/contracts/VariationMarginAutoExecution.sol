pragma solidity ^0.4.20;

/**
 * Add oraclize API
 */
//import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";
import "usingOraclize.sol";

/**
 * Allow Slice strings
 */
import "./strings.sol";

import "./CompensationChamber.sol";

contract VariationMarginAutoExecution is usingOraclize
{
      /**
       * To enable strings.sol library
       */
      using strings for *;

     /**
      * Number os seconds in 24 h
      */
      uint private dayInSeconds = 86400;

      bool firstQuery;

      uint timeUntilFirstVMRevisionInSeconds;

      address compensationChamberAddress;

    function VariationMarginAutoExecution(uint _timeUntilFirstVMRevisionInSeconds) public
    {
        compensationChamberAddress = msg.sender;
        firstQuery = true;
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
       //_compensationChamberObject.computeVariationMargin();
    }
}
