pragma solidity ^0.4.18;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "Utils.sol";
import "CompensationChamber.sol";
import "PaymentRequest.sol";


contract Market is OrderBookUtils
{
 enum instrumentType
  {
    future,
    swap
  }

  address compensationChamberAddress;
  order[] orders;

  modifier onlyCCP()
  {
      require(msg.sender == compensationChamberAddress);
      _;
  }

  mapping (bytes32 => address) mapInstrumentToOrderBookAddress;

  function Market() public
  {
    compensationChamberAddress = new CompensationChamber();
  }

  event payRequest(address _memberAddress, address _paymentAddress, uint _weiValue);

  function paymentRequest(address _memberAddress, address _paymentRequestAddress) public view onlyCCP
  {
      PaymentRequest _payRequest = PaymentRequest(_paymentRequestAddress);
      uint weiValue = _payRequest.getValue();
      payRequest(_memberAddress, _paymentRequestAddress, weiValue);
  }

  event paymentError(string);

  function payPaymentRequest(address _paymentRequestAddress) public payable
  {
      PaymentRequest _payRequest = PaymentRequest(_paymentRequestAddress);

      if (msg.value == _payRequest.getValue())
      {
          bool payed = _payRequest.pay.value(msg.value)();
          if (payed != true)
          {
              paymentError("An error occur during the payment");
          }

      }
      else
      {
          paymentError("The amount of the payment is not correct");
      }
  }


 /* function addFutureToCCP(address _longClearingMemberAddress, address _shortClearingMemberAddress, string _instrumentID, string _amount, uint _settlementTimestamp, address _marketDataAddress, string  _market) public payable
  {

  }

  function addSwapToCCP(address _fixedLegClearingMemberAddress, address _floatingLegClearingMemberAddress, string _instrumentID, string _nominal, uint _settlementTimestamp, address _marketDataAddress, string _market) public payable
  {

  }*/

}
