pragma solidity ^0.4.18;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "Utils.sol";
import "CompensationChamber.sol";
import "PaymentRequest.sol";
import "OrderBook.sol";

contract Market is OrderBookUtils
{
 enum instrumentType
  {
    future,
    swap
  }

  address compensationChamberAddress;
  order[] orders;

  mapping(string => address) mapInstrumentIdToOrderBookAddress;

  modifier onlyCCP()
  {
      require(msg.sender == compensationChamberAddress);
      _;
  }

  mapping (bytes32 => address) mapInstrumentToOrderBookAddress;

  function Market(uint timestampUntilNextVMRevision) public payable
  {
    compensationChamberAddress = (new CompensationChamber).value(msg.value)(timestampUntilNextVMRevision);
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

  // type equals buy or sell
  function addOrder(string _instrumentID, uint _quantity, uint _price, string _type)
  {
      address _orderBookAddress = mapInstrumentIdToOrderBookAddress[_instrumentID];

      if (_orderBookAddress != 0)
      {
          OrderBook _orderBook = OrderBook(_orderBookAddress);

          if (compareStrings(_type, "BUY"))
          {
              _orderBook.addBuyOrder(msg.sender, _quantity, _price);
          }
          else if (compareStrings(_type, "SELL"))
          {
              _orderBook.addSellOrder(msg.sender, _quantity, _price);
          }
      }
  }


  function addFutureToCCP(address _longClearingMemberAddress, address _shortClearingMemberAddress, string _instrumentID, string _amount, uint _settlementTimestamp, string  _market) public payable
  {
    CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
    _compensationChamber.futureNovation(_longClearingMemberAddress, _shortClearingMemberAddress, _instrumentID, _amount, _settlementTimestamp, _market);
  }

  function addSwapToCCP(address _fixedLegClearingMemberAddress, address _floatingLegClearingMemberAddress, string _instrumentID, string _nominal, uint _settlementTimestamp, string _market) public payable
  {
    CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
     _compensationChamber.swapNovation(_fixedLegClearingMemberAddress, _floatingLegClearingMemberAddress, _instrumentID, _nominal, _settlementTimestamp, _market);
  }

}
