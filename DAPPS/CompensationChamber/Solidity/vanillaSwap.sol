pragma solidity ^0.4.18;

/**
 * Add oraclize API
 */
import "./lib/oraclizeAPI.sol";

/**
 * Allow Slice strings
 */
import "./lib/strings.sol";

/**
 * De momento, la pata fija es a la par.
 */
import "./clearingMember.sol";
import "./CompensationChamber.sol";
import "./MarketData.sol";
/**
 * De momento, la pata fija es a la par.
 */
contract vanillaSwap is asset
{

  function vanillaSwap(address _marketDataAddress, address _floatingLegMemberContractAddress, address _fixedLegMemberContractAddress, uint _settlementDate, string _nominal, string _instrumentID)asset(_marketDataAddress, _floatingLegMemberContractAddress, _fixedLegMemberContractAddress, _settlementDate, _nominal) public payable
  {
    MarketData marketDataContract = MarketData(_marketDataAddress);
    marketDataContract.getIMSwap.value(2 ether)(_nominal, _instrumentID);
  }

  function setVariationMargin() view onlyChamber public
  {
    MarketData marketDataContract = MarketData(marketDataAddress);
    //marketDataContract.getVMSwap.value(2 ether)(_nominal, _instrumentID);
  }

}
