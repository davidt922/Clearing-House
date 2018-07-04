pragma solidity ^0.4.18;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "Utils.sol";
import "CompensationChamber.sol";


contract Market is OrderBookUtils
{
 enum instrumentType
  {
    future,
    swap
  }

  address compensationChamberAddress;
  order[] orders;

  mapping (bytes32 => address) mapInstrumentToOrderBookAddress;

  function Market() public
  {
    compensationChamberAddress = new CompensationChamber();
  }

 /* function addFutureToCCP(address _longClearingMemberAddress, address _shortClearingMemberAddress, string _instrumentID, string _amount, uint _settlementTimestamp, address _marketDataAddress, string  _market) public payable
  {

  }

  function addSwapToCCP(address _fixedLegClearingMemberAddress, address _floatingLegClearingMemberAddress, string _instrumentID, string _nominal, uint _settlementTimestamp, address _marketDataAddress, string _market) public payable
  {

  }*/

}
