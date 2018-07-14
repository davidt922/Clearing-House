pragma solidity ^0.4.20;

import "./strings.sol";

import "./Utils.sol";
import "./OrderBook.sol";
import "./CompensationChamber.sol";
import "./PaymentRequest.sol";

contract Market
{
    address compensationChamberAddress;
    address owner;

    mapping (string => address) mapInstrumentIdToOrderBookAddress;

    modifier onlyCCP()
    {
        require (msg.sender == compensationChamberAddress);
        _;
    }

    modifier onlyOwner()
    {
        require (msg.sender == owner);
        _;
    }

    function Market(uint timestampUntilNextVMRevision) public payable
    {
        require (msg.value >= 15 ether);

        owner = msg.sender;
        compensationChamberAddress = (new CompensationChamber).value(12 ether)(timestampUntilNextVMRevision);
        // Start for test
        CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
        _compensationChamber.addClearingMember(0x14723a09acff6d2a60dcdf7aa4aff308fddc160c);
        _compensationChamber.addClearingMember(0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db);
        // End for test
    }

    event logPaymentRequestAddress(address paymentRequestAddress, uint value, address clearingMemberAddress);

    function paymentRequest(address _paymentRequestAddress, uint _value, address _clearingMemberAddress) public onlyCCP
    {
        logPaymentRequestAddress(_paymentRequestAddress, _value, _clearingMemberAddress);
    }

    event logString(string);
    function payPaymentRequest(address _paymentRequestAddress) public payable
    {
        PaymentRequest _paymentRequestContract = PaymentRequest(_paymentRequestAddress);

        require (_paymentRequestContract.getValue() <= msg.value);
        bool result = _paymentRequestContract.pay.value(msg.value)();

        if (result == true)
        {
            string memory _result = Utils.strConcat("Payment request ", Utils.addressToString(_paymentRequestAddress), "Payed successfully");
            logString(_result);
        }
    }

    function addNewDerivative (string _instrumentID, string _market, Utils.instrumentType _instrumentType, uint _settlementTimestamp) public /*onlyOwner*/ payable
    {
        mapInstrumentIdToOrderBookAddress[_instrumentID] = new OrderBook(_instrumentID, _market, _instrumentType, _settlementTimestamp);
    }

    function addFutureToCCP(address _longClearingMemberAddress, address _shortClearingMemberAddress, string _instrumentID, string _amount, string _price, uint _settlementTimestamp, string  _market) public
    {
        CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
        _compensationChamber.futureNovation.value(1 ether)(_longClearingMemberAddress, _shortClearingMemberAddress, _instrumentID, _amount, _price, _settlementTimestamp, _market);
    }

    function addOrder(string _instrumentID, uint _quantity, uint _price, string _type) public payable
    {
        require (this.balance >= 1 ether);
        address _orderBookAddress = mapInstrumentIdToOrderBookAddress[_instrumentID];

        if (_orderBookAddress != 0)
        {
            OrderBook _orderBook = OrderBook(_orderBookAddress);

            if (Utils.compareStrings(_type, "BUY"))
            {
                _orderBook.addBuyOrder(msg.sender, _quantity, _price);
            }
            else if (Utils.compareStrings(_type, "SELL"))
            {
                _orderBook.addSellOrder(msg.sender, _quantity, _price);
            }
        }
    }

}
