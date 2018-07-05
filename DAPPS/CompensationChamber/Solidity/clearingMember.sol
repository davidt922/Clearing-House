pragma solidity ^0.4.20;

/**
 * Add oraclize api used for call a function every 24h and to obtain data from external sources
 */
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
/**
 * We will only have one instance of this contract, that will represent the compensation compensationChamber
 * All the contracts will be created using this one
 */

import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "Derivative.sol";
import "CompensationChamber.sol";

contract ClearingMember
{
  /**
   * Clearing member address
   * Compensation Chamber address
   * Array of addresses corresponding to the contracts that this clearing member have
   */
  address private memberAddress;
  address[] private derivatives;
  address private chamberAddress;
  address[] private payments;

  /**
   * Add modifiers for this contract, one for the chamber and the other for the clearing memeber
   */
  modifier onlyChamber
  {
    require(msg.sender == chamberAddress);
    _;
  }

  modifier onlyMember
  {
    require(msg.sender == memberAddress);
    _;
  }

  modifier onlyDerivatives
  {
    bool ownedDerivative = false;
    for (uint i = 0; i < derivatives.length; i++)
    {
        if (derivatives[i] == msg.sender)
        {
            ownedDerivative = true;
        }
    }
    require(ownedDerivative);
    _;
  }

  function ClearingMember(address _clearingMemberAddress) public
  {
    memberAddress = _clearingMemberAddress;
    chamberAddress = msg.sender;
  }

  function addDerivative(address _derivativeAddress) public onlyChamber
  {
    derivatives.push(_derivativeAddress);
  }

  function getDerivatives() public returns(address[])
  {
      return derivatives;
  }

  function paymentRequest(address _paymentAddress) public onlyDerivatives
  {
      payments.push(_paymentAddress);
      CompensationChamber _compensationChamber = CompensationChamber(chamberAddress);
  }
}
