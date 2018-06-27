pragma solidity ^0.4.18;

/**
 * Add oraclize API
 */
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

/**
 * Allow Slice strings
 */
import "github.com/Arachnid/solidity-stringutils/strings.sol";

/**
 * De momento, la pata fija es a la par.
 */

contract vanillaSwap
{
  using strings for *;

  address marketDataAddress;
  address floatingLegMemberAddress;
  address fixedLegMemberAddress;
  uint tradeDate;
  uint settlementDate;
  string nominal;

  function vanillaSwap(address _marketDataAddress, address _floatingLegMemberAddress, address _fixedLegMemberAddress, uint _settlementDate, string _nominal, string _instrumentID) public payable
  {
    marketDataAddress = _marketDataAddress;
    floatingLegMemberAddress = _floatingLegMemberAddress;
    fixedLegMemberAddress = _fixedLegMemberAddress;
    settlementDate = _settlementDate;
    nominal = _nominal;
    tradeDate = block.timestamp;
    MarketData marketDataContract = MarketData(marketDataAddress);
    marketDataContract.getIMSwap.value(5 ether)(_nominal, _instrumentID);
  }

  modifier onlyMarketData
  {
    require(msg.sender == marketDataAddress);
    _;
  }

  event showValue(string a);

  function setIM(string result) view onlyMarketData public
  {

    var stringToParse = result.toSlice();
    stringToParse.beyond("[".toSlice()).until("]".toSlice()); //remove [ and ]
    var delim = ",".toSlice();
    var parts = new string[](stringToParse.count(delim) + 1);

    for (uint i = 0; i < parts.length; i++)
    {
        parts[i] = stringToParse.split(delim).toString();
    }

    clearingMember floatingLeg = clearingMember(floatingLegMemberAddress);
    clearingMember fixedLeg = clearingMember(fixedLegMemberAddress);

    floatingLeg.addVanillaSwap(parts[0]);
    fixedLeg.addVanillaSwap(parts[1]);
  }

}
