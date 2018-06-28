pragma solidity ^0.4.18;

import "./strings.sol";
import "./conversions.sol";

contract asset is conversions
{
  using strings for *;

  address marketDataAddress;
  address compensationChamberAddress;
  address contractAddress1; //floating leg
  address contractAddress2; //fixed leg
  uint tradeDate;
  uint settlementDate;
  string nominal;

  /**
   * Map the contractAddress1 and 2 to the value of initial margin they have to pay
   */
  mapping(address => bytes32) initialMargin;
  /**
   * Map the contractAddress1 and 2 to the value of variation margin they have to pay
   * these value change every day
   */
  mapping(address => bytes32) variationMargin;

  modifier onlyMarketData
  {
    require(msg.sender == marketDataAddress);
    _;
  }

  modifier onlyChamber
  {
    require(msg.sender == compensationChamberAddress);
    _;
  }

  function asset(address _marketDataAddress, address _contractAddress1, address _contractAddress2, uint _settlementDate, string _nominal) public
  {
    marketDataAddress = _marketDataAddress;
    contractAddress1 = _contractAddress1; //floating leg
    contractAddress2 = _contractAddress2; //fixed leg
    tradeDate = block.timestamp;
    settlementDate = _settlementDate;
    nominal = _nominal;
    compensationChamberAddress = msg.sender;
    variationMargin[contractAddress1] = "0x0";
    variationMargin[contractAddress2] = "0x0";
  }

  function getIM(address contractAddress) public returns(bytes32)
  {
    return initialMargin[contractAddress];
  }
  // This function could only be executed by the asset holder's
  function getIM() public returns(bytes32)
  {
    return initialMargin[msg.sender];
  }

  function getClearingMemberContractAddressOfTheAsset() public onlyChamber returns(address[2])
  {
    return [contractAddress1, contractAddress2];
  }

  function setIM(string result) view onlyMarketData public
  {

     /*
    bytes32[] memory parts = stringToBytes32Array(result);

    clearingMember clearingMember1 = clearingMember(contractAddress1);
    clearingMember clearingMember2 = clearingMember(contractAddress2);

    initialMargin[contractAddress1] = parts[0];
    initialMargin[contractAddress2] = parts[1];

    clearingMember1.addAsset();
    clearingMember2.addAsset();*/
  }
}
