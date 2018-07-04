pragma solidity ^0.4.18;

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

contract clearingMember
{
  /**
   * Clearing member address
   * Compensation Chamber address
   * Array of addresses corresponding to the contracts that this clearing member have
   */
  address private memberAddress;
  address[] private assets;
  address private chamberAddress;

  /**
   * Events
   */
   event initialMargin(string price);
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

  function clearingMember(address _clearingMemberAddress) public
  {
    memberAddress = _clearingMemberAddress;
    chamberAddress = msg.sender;
  }

  function addAsset(bytes32 _initialMargin) public
  {
    CompensationChamber _compensationChamber = CompensationChamber(chamberAddress);
    //_compensationChamber.sendInitialMarginInformation(_initialMargin);
    assets.push(msg.sender);
  }
  function getAssets() public returns(address[])
  {
      return assets;
  }

  function getInitialMargin(address assetAddress) public view returns(uint)
  {
    Derivative _derivative = Derivative(assetAddress);
    return _derivative.getIM();
  }
}
