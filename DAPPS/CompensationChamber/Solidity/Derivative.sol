pragma solidity ^0.4.20;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "Utils.sol";

import "PaymentRequest.sol";
import "ClearingMember.sol";



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

// initial margin will store PaymentRequest address
  mapping(address => address) initialMargin;


  // variationMargin will store variationMarginStruct structs


  mapping(address => uint) lastVariationMargin;
  mapping(address => uint) accumulatedVariationMargin;

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
  function Derivative(string _instrumentID, uint _settlementTimestamp, address _marketDataAddress, string _market) public
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
  function setIM(string result) onlyMarketData public;

  /**
  * Set variationMargin
  */
  function setVM(string result) private
  {}

  /**
  * Getters
  */
  function getIM() public returns(uint)
  {
      PaymentRequest _IMPayment = PaymentRequest(msg.sender);
      return _IMPayment.getValue();
  }

  function getIM(address _contractAddress) public returns(uint)
  {
      PaymentRequest _IMPayment = PaymentRequest(_contractAddress);
      return _IMPayment.getValue();
  }

  function getVM() public returns(uint)
  {
   /* address[] _paymentAddressArray = variationMargin[msg.sender];
    address _lastVMPaymentAddress = _paymentAddressArray[_paymentAddressArray.length - 1];

    PaymentRequest _lastVMPayment = PaymentRequest(_lastVMPaymentAddress);
    return _lastVMPayment.getValue();*/
  }

  function getVM(address _contractAddress) public returns(uint)
  {
 /*   address[] _paymentAddressArray = variationMargin[_contractAddress];
    address _lastVMPaymentAddress = _paymentAddressArray[_paymentAddressArray.length - 1];

    PaymentRequest _lastVMPayment = PaymentRequest(_lastVMPaymentAddress);
    return _lastVMPayment.getValue();*/
  }

  //function getUnpayedVM() public returns(uint);

  function getSettlementTimestamp() public returns(uint)
  {
    return settlementTimestamp;
  }

  function getTradeTimestamp() public returns(uint)
  {
    return tradeTimestamp;
  }

  function paymentRequest(uint _value, address _clearingMemberContractAddress, paymentType _type) /*internal*/
  {
      address paymentAddress;

      ClearingMember _clearingMember = ClearingMember(_clearingMemberContractAddress);

      //if(_type == paymentType.initialMargin)
      //{
          //paymentAddress = new Test();
          paymentAddress = new PaymentRequest(_value, _clearingMemberContractAddress, _type);
          initialMargin[_clearingMemberContractAddress] = paymentAddress;

          _clearingMember.paymentRequest(paymentAddress);
     // }
     // else
     // {
          //paymentAddress = new PaymentRequest(_value, _clearingMemberContractAddress, _type);
         // variationMargin[_clearingMemberContractAddress].push(paymentAddress);

         // _clearingMember.paymentRequest(paymentAddress);
     // }
  }

  function getTheContractCounterparts() public returns(address[2]);

  function computeVM() public onlyChamber returns (variationMarginChange[2]);
}
