pragma solidity ^0.4.18;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "Utils.sol";
import "Payment.sol";

/**
 * Derivative is an abstract contract: Contracts are marked as abstract when at
 * least one of their functions lacks an implementation as in the following
 * example (note that the function declaration header is terminated by ;):
 */
contract Derivative is Utils
{
  string instrumentID;
  string market;

  address marketDataAddress;
  address compensationChamberAddress;

  uint tradeTimestamp;
  uint settlementTimestamp;

  mapping(address => address) initialMargin;
  mapping(address => address[]) variationMargin;

  /**
   * Modifiers
   */

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

  /**
   * Map the payments relates a clearing member address with a Payment contract
   * inside the payment contract there is all the information related with the payments
   * that the clearing member have to do
   */
  mapping(address => address) payments;

  /**
   * Constructor
   */
  function derivate(string _instrumentID, uint _settlementTimestamp, address _marketDataAddress, string _market) public
  {
    instrumentID = _instrumentID;
    market = _market;

    marketDataAddress = _marketDataAddress;
    compensationChamberAddress = msg.sender;

    settlementTimestamp = _settlementTimestamp;
    tradeTimestamp = block.timestamp;
  }

  /**
  * Set initialMargin
  */
  function setIM(address _clearingMemberAddress, uint _value)
  {
    initialMargin[_clearingMemberAddress] = new Payment(_value, _clearingMemberAddress, 1);
  }

  /**
  * Set initialMargin
  */
  function setVM(address _clearingMemberAddress, uint _value)
  {
    variationMargin[_clearingMemberAddress].push(new Payment(_value, _clearingMemberAddress, 1));
  }

  /**
  * Getters
  */
  function getIM() public returns(uint)
  {
      Payment _IMPayment = Payment(msg.sender);
      return _IMPayment.getValue();
  }

  function getIM(address _contractAddress) public returns(uint)
  {
      Payment _IMPayment = Payment(_contractAddress);
      return _IMPayment.getValue();
  }

  function getVM() public returns(uint)
  {
    address[] _paymentAddressArray = variationMargin[msg.sender];
    address _lastVMPaymentAddress = _paymentAddressArray[_paymentAddressArray.length - 1];

    Payment _lastVMPayment = Payment(_lastVMPaymentAddress);
    return _lastVMPayment.getValue();
  }

  function getVM(address _contractAddress) public returns(uint)
  {
    address[] _paymentAddressArray = variationMargin[_contractAddress];
    address _lastVMPaymentAddress = _paymentAddressArray[_paymentAddressArray.length - 1];

    Payment _lastVMPayment = Payment(_lastVMPaymentAddress);
    return _lastVMPayment.getValue();
  }

  function getUnpayedVM() public returns(uint);

  function getSettlementTimestamp() public returns(uint)
  {
    return settlementTimestamp;
  }

  function getTradeTimestamp() public returns(uint)
  {
    return tradeTimestamp;
  }

  function getTheContractCounterparts() public returns(address[2]);

  function payIM() public payable
  {

  }

}
