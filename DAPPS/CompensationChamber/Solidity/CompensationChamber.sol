pragma experimental ABIEncoderV2;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "Utils.sol";
import "MarketData.sol";
import "Market.sol";
import "ClearingMember.sol";
import "PaymentRequest.sol";
//import "Derivative.sol";
import "Future.sol";
import "VariationMargin.sol";

import "SafeMath.sol";

contract CompensationChamber is Utils
{
  /**
   * Constants
   */

 /**
  * Number os seconds in 24 h
  */
  uint private dayInSeconds = 86400;

  /**
   * Time that the clearing members have to pay the margin after the chamber send
   * the margin (12 h)
   */
  uint private timeToPayTheMargin = 43200;

  /**
   * Addres of the owner of the CCP, and the address of the
   * market and market data smartcontracts and the settlement
   * The settlement is the place were the assets will be registred
   */
  address private marketAddress;
  address private marketDataAddress;
  address private settlementAddress;

  /**
  * Modifiers
  */

  modifier onlyMarket
  {
    require(msg.sender == marketAddress);
    _;
  }

  modifier onlySettlement
  {
    require(msg.sender == settlementAddress);
    _;
  }

  modifier onlyMarketData
  {
    require(msg.sender == marketDataAddress);
    _;
  }

  modifier onlyClearingMemberContracts
  {
    bool isClearingMemberContract = false;
    for (uint i = 0; i < clearingMemberContractAddresses.length; i++)
    {
        if (clearingMemberContractAddresses[i] == msg.sender)
        {
            isClearingMemberContract = true;
        }
    }
    require(isClearingMemberContract);
    _;
  }

  /**
   * Map of the clearing member address with her smartcontract address
   */
  mapping (address => address) mapClearingMemberAddressToClearingMemberContractAddress;
  mapping (address => address) mapClearingMemberContractAddressToClearingMemberAddress;
  address[] clearingMembersAddresses;
  address[] clearingMemberContractAddresses;

  /**
   * Array of addresses of all the derivatives that the compensation chamber hold
   */
  address[] derivatives;

  function CompensationChamber(uint timestampUntilNextVMRevision) public payable
  {
    marketAddress = msg.sender;
    marketDataAddress = (new MarketData).value(5 ether)();
    uint timeUntilFirstVMRevisionInSeconds = timestampUntilNextVMRevision - block.timestamp;
    new VariationMargin(timeUntilFirstVMRevisionInSeconds);
   // settlementAddress = (new Settlement).value(5 ether)();

  }

  function addClearingMember(address _clearingMemberAddress)
  {
    address contractAddress = mapClearingMemberAddressToClearingMemberContractAddress[_clearingMemberAddress];

    if(contractAddress == 0)
    {
      mapClearingMemberAddressToClearingMemberContractAddress[_clearingMemberAddress] = new ClearingMember(_clearingMemberAddress);
      mapClearingMemberContractAddressToClearingMemberAddress[mapClearingMemberAddressToClearingMemberContractAddress[_clearingMemberAddress]] = _clearingMemberAddress;
      clearingMembersAddresses.push(_clearingMemberAddress);
      clearingMemberContractAddresses.push(mapClearingMemberAddressToClearingMemberContractAddress[_clearingMemberAddress]);
    }
    else
    {
      //revert("There is a contract of a liquidator member linked to this address");
    }
  }

  /**
   * Getters
   */

  function getMarketDataAddress() public returns(address)
  {
    return marketDataAddress;
  }

  function getMarketAddress() public returns(address)
  {
    return marketAddress;
  }

  function getSettlementAddress() public returns(address)
  {
    return settlementAddress;
  }

  function getClearingMemberContractAddress(address _clearingMemberAddress) private returns(address clearingMemberContractAddresses)
  {
    address _contractAddress = mapClearingMemberAddressToClearingMemberContractAddress[_clearingMemberAddress];

    if( _contractAddress == 0)
    {
      //revert("There is a contract of a liquidator member linked to this address");
    }
    else
    {
      return _contractAddress;
    }
  }

  /**
   * Products
   */

  // onlyMarket modifier
  function futureNovation(address _longClearingMemberAddress, address _shortClearingMemberAddress, string _instrumentID, string _amount, uint _settlementTimestamp, string  _market) public payable
  {
    require(msg.value >= 1 ether);
    address _longClearingMemberContractAddress = getClearingMemberContractAddress(_longClearingMemberAddress);
    address _shortClearingMemberContractAddress = getClearingMemberContractAddress(_shortClearingMemberAddress);

      Market _marketObject = Market(marketAddress);
    _marketObject.logAddress(_longClearingMemberContractAddress);
    _marketObject.logAddress(_longClearingMemberContractAddress);
    _marketObject.logInt(msg.value);
    derivatives.push((new Future).value(msg.value)(_longClearingMemberContractAddress, _shortClearingMemberContractAddress, _instrumentID, _amount, _settlementTimestamp, marketDataAddress, _market));
  }

  function swapNovation(address _fixedLegClearingMemberAddress, address _floatingLegClearingMemberAddress, string _instrumentID, string _nominal, uint _settlementTimestamp, string _market) public payable
  {
     require(msg.value >= 1 ether);
    address _fixedLegClearingMemberContractAddress = getClearingMemberContractAddress(_fixedLegClearingMemberAddress);
    address _floatingLegClearingMemberContractAddress = getClearingMemberContractAddress(_floatingLegClearingMemberAddress);

   // derivatives.push((new Swap).value(1 ether)(_fixedLegClearingMemberContractAddress, _floatingLegClearingMemberContractAddress, _instrumentID, _nominal, _settlementTimestamp, _marketDataAddress, _market));
  }

  //function forwardNovation()

  //function optionNovation()

  function sendPaymentRequestToMarket(address _paymentRequest) public onlyClearingMemberContracts
  {
      Market _market = Market(marketAddress);
      PaymentRequest _paymentRequestObject = PaymentRequest(_paymentRequest);
      _market.paymentRequest(mapClearingMemberContractAddressToClearingMemberAddress[_paymentRequestObject.getClearingMember()], _paymentRequest);
  }

  function sendPaymentRequestToMarketParamContractAddress(address _clearingMemberContractAddress) public onlyClearingMemberContracts
  {
      Market _market = Market(marketAddress);
      _market.paymentRequest(mapClearingMemberContractAddressToClearingMemberAddress[_clearingMemberContractAddress], msg.sender);
  }


  // Logs

  function logIntToMarket(uint a)
  {
      Market _marketObject = Market(marketAddress);
      _marketObject.logInt(a);
  }

  // Compute
  uint counter;
  mapping (address => uint) mapAddressToTotalVM;



  function computeVariationMargin() public
  {

      counter = derivatives.length * 2;

      variationMarginChange[2] memory varMarginChangeArray;

      for (uint i = 0; i < derivatives.length; i++)
      {
          Derivative _derivative = Derivative(derivatives[i]);
          varMarginChangeArray = _derivative.computeVM();

          variationMargin(varMarginChangeArray[0]);
          variationMargin(varMarginChangeArray[1]);

      }
  }

  mapping (address => int) mapAddressToVMValue;

  function variationMargin(variationMarginChange _VMStruct)
  {
      counter = counter - 1;

        mapAddressToVMValue[_VMStruct.clearingMemberContractAddress] = mapAddressToVMValue[_VMStruct.clearingMemberContractAddress] + _VMStruct.value;

      if (counter == 0)
      {
          sendPaymentRequestOrSendPayment();
          removeMapAddressToVMValue();
      }
  }

  function sendPaymentRequestOrSendPayment()
  {
      int value;
      address clearingMemberContractAddress;

      address paymentRequest;

      for (uint i = 0; i < clearingMemberContractAddresses.length; i++)
      {
          clearingMemberContractAddress = clearingMemberContractAddresses[i];
          value = mapAddressToVMValue[clearingMemberContractAddress];

          if (value > 0)
          {
              paymentRequest = new PaymentRequest( uint(value), clearingMemberContractAddress, paymentType.variationMargin);
              sendPaymentRequestToMarket(paymentRequest);
          }
          else if (value < 0)
          {
              mapClearingMemberContractAddressToClearingMemberAddress[clearingMemberContractAddress].send( uint(value/-1));
          }
      }
  }

  function removeMapAddressToVMValue() private
  {
      for (uint i = 0; i < clearingMemberContractAddresses.length; i++)
      {
          mapAddressToVMValue[clearingMemberContractAddresses[i]] = 0;
      }
  }

}
