pragma experimental ABIEncoderV2;

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
    string[] availableInstrumentIDs;

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

    event logRegInfo(string getString);
    event logString(string getString);

    event logAddressID(int addressID);

    event logBytes32(bytes32 getBytes32);

    event logMarketOrder(string instrumentID, uint quantity, uint price, string side);

    event logInstruments(string instrumentID);

    function Market(uint timestampUntilNextVMRevision) public payable
    {
        require (msg.value >= 15 ether);

        owner = msg.sender;
        compensationChamberAddress = (new CompensationChamber).value(12 ether)(timestampUntilNextVMRevision);
    }

    function addClearingMember(string _name, string _email, string _password)
    {
       //Start for test
      CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
      int addressID = _compensationChamber.addClearingMember(_name, _email, msg.sender, _password);

      if (addressID == -1)
      {
          logRegInfo("This email is alredy register");
      }
      else
      {
          logRegInfo("Registration done!");
      }
      logAddressID(addressID);
      // End for test
    }

    function confirmClearingMemberAddress(string email)
    {
      CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
      _compensationChamber.confirmClearingMember(msg.sender, email);
    }

    event logPaymentRequestAddress(address paymentRequestAddress, uint value, address clearingMemberAddress);

    function paymentRequest(address _paymentRequestAddress, uint _value, address _clearingMemberAddress) public onlyCCP
    {
        logPaymentRequestAddress(_paymentRequestAddress, _value, _clearingMemberAddress);
    }

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
      if (mapInstrumentIdToOrderBookAddress[_instrumentID] == 0)
      {
        mapInstrumentIdToOrderBookAddress[_instrumentID] = new OrderBook(_instrumentID, _market, _instrumentType, _settlementTimestamp);
        availableInstrumentIDs.push(_instrumentID);
      }
    }

    function addFutureToCCP(address _longClearingMemberAddress, address _shortClearingMemberAddress, string _instrumentID, string _amount, string _price, uint _settlementTimestamp, string  _market) public
    {
      logString("ADDED TO MARKET");
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

    function signIn(string _email, string _password) public returns (int addressID, string name, address compensationMemberAddress)
    {
      CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
      var( _addressID, _name, _compensationMemberAddress )=_compensationChamber.checkSignInEmailAndPassword(_email, _password);

      addressID = _addressID;
      name = _name;
      compensationMemberAddress = _compensationMemberAddress;
    }

    mapping(uint => string) sideMap;

    function getInstruments() public
    {
      for (uint i = 0; i < availableInstrumentIDs.length; i++)
      {
        emit logInstruments(availableInstrumentIDs[i]);
      }
    }

    function getMarket() public
    {
      sideMap[0] = "ASK";
      sideMap[1] = "BID";

      for (uint i = 0; i < availableInstrumentIDs.length; i++)
      {
        address _orderBookAddress = mapInstrumentIdToOrderBookAddress[availableInstrumentIDs[i]];
        OrderBook _orderBook = OrderBook(_orderBookAddress);

        string memory _instrumentID = _orderBook.getInstrumentID();

        uint askLength = _orderBook.getAskOrdersLength();

        if (askLength > 4)
        {
          askLength = 4;
        }

        Utils.marketOrder memory _marketOrder ;
        uint j;
        for (j = 0; j < askLength; j++)
        {
          _marketOrder = _orderBook.getAskOrders(j);
          emit logMarketOrder(_instrumentID, _marketOrder.quantity, _marketOrder.price, "ASK");
        }

        uint bidLength = _orderBook.getBidOrdersLength();

        if (bidLength > 4)
        {
          bidLength = 4;
        }

        for (j = 0; j < bidLength; j++)
        {
          _marketOrder = _orderBook.getBidOrders(j);
          emit logMarketOrder(_instrumentID, _marketOrder.quantity, _marketOrder.price, "BID");
        }

      }
    }

}
