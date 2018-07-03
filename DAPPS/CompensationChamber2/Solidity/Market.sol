pragma solidity ^0.4.18;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";


contract Market is Utils
{
  enum side
  {
    short,
    long
  }

  address compensationChamberAddress;
  order[] orders;

  mapping (bytes32 => address) mapInstrumentToOrderBookAddress;

  function Market() public
  {
    compensationChamberAddress = new CompensationChamber();
  }

  function addOrder()
  {

  }

}
