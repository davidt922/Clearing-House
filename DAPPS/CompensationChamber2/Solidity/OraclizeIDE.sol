pragma experimental ABIEncoderV2;

//import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "OraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";


library Utils
{
  using strings for *;

    struct order
    {
        address clearingMemberAddress;
        uint quantity;
        uint timestamp;
        uint price; // the las 3 numbers of the integer represents the decimals, so 3000 equals to 3.
    }

    enum instrumentType
    {
        future,
        swap
    }

    enum paymentType
    {
        initialMargin,
        variationMargin
    }

    struct variationMarginChange
    {
        address clearingMemberAddress;
        int value;
    }

    // Convert from bytes32 to String
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string)
    {
        bytes memory bytesArray = new bytes(32);
        for (uint256 i; i < 32; i++)
        {
        bytesArray[i] = _bytes32[i];
        }

        var stringToParse = string(bytesArray).toSlice();
        strings.slice memory part;

        // remove all \u0000 after the word
        stringToParse.split("\u0000".toSlice(), part);
        return part.toString();
    }

    // Convert addressToString
    function addressToString(address x) internal pure returns (string)
    {
        bytes memory b = new bytes(20);

        for (uint i = 0; i < 20; i++)
        {
            b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
        }
        return string(b);
    }

    // Convert string to bytes32
    function stringToBytes32(string memory source) internal pure returns (bytes32 result)
    {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0)
        {
            return 0x0;
        }
        assembly
        {
            result := mload(add(source, 32))
        }
    }
    // Convert string to Uint
    function stringToUint(string s) internal pure returns (uint result)
    {
        bytes memory b = bytes(s);
        uint i;
        result = 0;

        for (i = 0; i < b.length; i++)
        {
            uint c = uint(b[i]);

            if (c >= 48 && c <= 57)
            {
                result = result * 10 + (c - 48);
            }
        }
    }

    // convert string of type: [aa, cc] to an array of bytes32 ["aa", "cc"]
    function stringToBytes32Array2(string result) internal pure returns (bytes32[2] memory)
    {
        var stringToParse = result.toSlice();
        stringToParse.beyond("[".toSlice()).until("]".toSlice()); //remove [ and ]
        var delim = ",".toSlice();
        bytes32[2] memory parts;

        for (uint i = 0; i < parts.length; i++)
        {
            parts[i] = stringToBytes32(stringToParse.split(delim).toString());
        }

        return parts;
    }

    // Convert string of type: [aa, cc] to an array of uint ["aa", "cc"]
    function stringToUintArray2(string result) internal pure returns (uint[2] memory)
    {
        var stringToParse = result.toSlice();
        stringToParse.beyond("[".toSlice()).until("]".toSlice()); //remove [ and ]
        var delim = ",".toSlice();
        uint[2] memory parts;

        for (uint i = 0; i < parts.length; i++)
        {
            parts[i] = stringToUint(stringToParse.split(delim).toString());
        }
        return parts;
    }

    function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string)
    {
        bytes memory _ba = bytes(_a);
        bytes memory _bb = bytes(_b);
        bytes memory _bc = bytes(_c);
        bytes memory _bd = bytes(_d);
        bytes memory _be = bytes(_e);
        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
        bytes memory babcde = bytes(abcde);
        uint k = 0;
        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
        return string(babcde);
    }

    function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string)
    {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string _a, string _b, string _c) internal pure returns (string)
    {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string _a, string _b) internal pure returns (string)
    {
        return strConcat(_a, _b, "", "", "");
    }

    function removeUint(uint[] array, uint index)  internal pure returns(uint[])
    {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++)
        {
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        return array;
    }

    function removeAddress(address[] array, uint index) internal pure returns(address[])
    {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++)
        {
            array[i] = array[i+1];
        }
        delete array[array.length-1];
        return array;
    }

    function compareStrings (string a, string b) internal pure returns (bool)
    {
        return keccak256(a) == keccak256(b);
    }

    // Convert Uint to bytes32
    function uintToBytes(uint v) internal pure returns (bytes32 ret)
    {
        if (v == 0)
        {
            ret = '0';
        }
        else
        {
            while (v > 0)
            {
                ret = bytes32(uint(ret) / (2 ** 8));
                ret |= bytes32(((v % 10) + 48) * 2 ** (8 * 31));
                v /= 10;
            }
        }
        return ret;
    }

    // convert 123332 to 123.321
    function uintPriceToString(uint price) internal pure returns(string)
    {
        uint _int = uint(price/1000);
        uint _v = _int * 1000;
        uint _dec = price - _v;

        bytes32 _intBytes32 = uintToBytes(_int);
        bytes32 _decBytes32 = uintToBytes(_dec);
        string memory _intString = bytes32ToString(_intBytes32);
        string memory _decString = bytes32ToString(_decBytes32);

        return strConcat(_intString,".",_decString);
    }

    function uintToString(uint value) internal pure returns(string)
    {
        bytes32 _value = uintToBytes(value);
        string memory _valueString = bytes32ToString(_value);

        return _valueString;
    }

    function removeOrder(order[] storage array, uint index) internal
    {
        if (index >= array.length) return;

        for (uint i = index; i<array.length-1; i++)
        {
            array[i] = array[i+1];
        }
        delete array[array.length-1];
    }

}

contract QuickSortOrder
{
    event sortDone(string a);

  function orderIncreasing(Utils.order[] storage arr) internal
  {
      if(arr.length <= 1)
      {
          return;
      }
      else if(arr.length == 2)
      {
          if(arr[0].price > arr[1].price)
          {
            (arr[uint(0)].price, arr[uint(1)].price) = (arr[uint(1)].price, arr[uint(0)].price);
            (arr[uint(0)].quantity, arr[uint(1)].quantity) = (arr[uint(1)].quantity, arr[uint(0)].quantity);
            (arr[uint(0)].clearingMemberAddress, arr[uint(1)].clearingMemberAddress) = (arr[uint(1)].clearingMemberAddress, arr[uint(0)].clearingMemberAddress);
            (arr[uint(0)].timestamp, arr[uint(1)].timestamp) = (arr[uint(1)].timestamp, arr[uint(0)].timestamp);
          }
      }
      else
      {
        quickSortIncreasing(arr, 0, arr.length - 1);
      }

    for (uint i = 0; i < arr.length - 1; i++)
    {
        if (arr[i].price == arr[i+1].price)
        {
            if (arr[i].timestamp > arr[i+1].timestamp)
            {
                (arr[uint(i)].price, arr[uint(i+1)].price) = (arr[uint(i+1)].price, arr[uint(i)].price);
                (arr[uint(i)].quantity, arr[uint(i+1)].quantity) = (arr[uint(i+1)].quantity, arr[uint(i)].quantity);
                (arr[uint(i)].clearingMemberAddress, arr[uint(i+1)].clearingMemberAddress) = (arr[uint(i+1)].clearingMemberAddress, arr[uint(i)].clearingMemberAddress);
                (arr[uint(i)].timestamp, arr[uint(i+1)].timestamp) = (arr[uint(i+1)].timestamp, arr[uint(i)].timestamp);
            }
        }
    }
  }

  function orderDecreasing(Utils.order[] storage arr) internal
  {
      if(arr.length <= 1)
      {
          return;
      }
      else if(arr.length == 2)
      {
          if(arr[0].price < arr[1].price)
          {
            (arr[uint(0)].price, arr[uint(1)].price) = (arr[uint(1)].price, arr[uint(0)].price);
            (arr[uint(0)].quantity, arr[uint(1)].quantity) = (arr[uint(1)].quantity, arr[uint(0)].quantity);
            (arr[uint(0)].clearingMemberAddress, arr[uint(1)].clearingMemberAddress) = (arr[uint(1)].clearingMemberAddress, arr[uint(0)].clearingMemberAddress);
            (arr[uint(0)].timestamp, arr[uint(1)].timestamp) = (arr[uint(1)].timestamp, arr[uint(0)].timestamp);
          }
      }
      else
      {
        quickSortDecreasing(arr, 0, arr.length - 1);
      }

    for (uint i = 0; i < arr.length - 1; i++)
    {
        if (arr[i].price == arr[i+1].price)
        {
            if (arr[i].timestamp < arr[i+1].timestamp)
            {
                (arr[uint(i)].price, arr[uint(i+1)].price) = (arr[uint(i+1)].price, arr[uint(i)].price);
                (arr[uint(i)].quantity, arr[uint(i+1)].quantity) = (arr[uint(i+1)].quantity, arr[uint(i)].quantity);
                (arr[uint(i)].clearingMemberAddress, arr[uint(i+1)].clearingMemberAddress) = (arr[uint(i+1)].clearingMemberAddress, arr[uint(i)].clearingMemberAddress);
                (arr[uint(i)].timestamp, arr[uint(i+1)].timestamp) = (arr[uint(i+1)].timestamp, arr[uint(i)].timestamp);
            }
        }
    }
  }

  function quickSortIncreasing(Utils.order[] storage arr, uint left, uint right) internal
  {
         uint i = left;
         uint j = right;

        if(i==j)
        {
            return;
        }

         uint pivot = arr[uint(left + (right - left) / 2)].price;

         while (i <= j)
         {
            while (arr[uint(i)].price < pivot)
            {
                i++;
            }

            while (pivot < arr[uint(j)].price)
            {
               j--;
            }

           if (i <= j)
           {
               (arr[uint(i)].price, arr[uint(j)].price) = (arr[uint(j)].price, arr[uint(i)].price);
               (arr[uint(i)].quantity, arr[uint(j)].quantity) = (arr[uint(j)].quantity, arr[uint(i)].quantity);
               (arr[uint(i)].clearingMemberAddress, arr[uint(j)].clearingMemberAddress) = (arr[uint(j)].clearingMemberAddress, arr[uint(i)].clearingMemberAddress);
               (arr[uint(i)].timestamp, arr[uint(j)].timestamp) = (arr[uint(j)].timestamp, arr[uint(i)].timestamp);
               i++;
               j--;
           }
         }

         if (left < j)
         {
            quickSortIncreasing(arr, left, j);
         }

         if (i < right)
         {
            quickSortIncreasing(arr, i, right);
         }
    }

    function quickSortDecreasing(Utils.order[] storage arr, uint left, uint right) internal
    {
        quickSortIncreasing(arr, left,right);

        uint i = 0;
        uint j = arr.length - 1;

        while(i <= j)
        {
               (arr[uint(i)].price, arr[uint(j)].price) = (arr[uint(j)].price, arr[uint(i)].price);
               (arr[uint(i)].quantity, arr[uint(j)].quantity) = (arr[uint(j)].quantity, arr[uint(i)].quantity);
               (arr[uint(i)].clearingMemberAddress, arr[uint(j)].clearingMemberAddress) = (arr[uint(j)].clearingMemberAddress, arr[uint(i)].clearingMemberAddress);
               (arr[uint(i)].timestamp, arr[uint(j)].timestamp) = (arr[uint(j)].timestamp, arr[uint(i)].timestamp);
               i++;
               j--;
        }
    }

}


contract OrderBook is QuickSortOrder
{
    Utils.instrumentType instType;
    string instrumentID;
    string market;
    uint settlementTimestamp;

    address marketAddress;

    // ASK are sell orders
    Utils.order[] askOrders;
    // BID are buy orders
    Utils.order[] bidOrders;

    modifier onlyMarket()
    {
        require (marketAddress == msg.sender);
        _;
    }

    function OrderBook(string _instrumentID, string _market, Utils.instrumentType _instrumentType, uint _settlementTimestamp) public
    {
        instrumentID = _instrumentID;
        market = _market;
        instType = _instrumentType;
        marketAddress = msg.sender;
        settlementTimestamp = _settlementTimestamp;
    }
    // In this case we consider than _clearingMemberAddress is equals to _MarketMemberAddress
    function addBuyOrder(address _clearingMemberAddress, uint _quantity, uint _price) public onlyMarket
    {
        if (askOrders.length != 0)
        {
            uint i = 0;
            Market _marketContract = Market(marketAddress);

            while (_price <= askOrders[i].price || _quantity > 0)
            {
                if (_quantity >= askOrders[i].quantity)
                {
                    if (instType == Utils.instrumentType.future)
                    {
                        _marketContract.addFutureToCCP(_clearingMemberAddress, askOrders[i].clearingMemberAddress, instrumentID, Utils.uintToString(askOrders[i].quantity), Utils.uintPriceToString(askOrders[i].price), settlementTimestamp, market);
                    }
                    else if (instType == Utils.instrumentType.swap)
                    {
                        //_marketContract.addSwapToCCP(_clearingMemberAddress, askOrders[i].clearingMemberAddress, instrumentID, Utils.uintToString(askOrders[i].quantity), Utils.uintPriceToString(askOrders[i].price), settlementTimestamp, market);
                    }

                    _quantity = _quantity - askOrders[i].quantity;
                    Utils.removeOrder(askOrders, i);
                    i--;
                }
                else
                {
                    if (instType == Utils.instrumentType.future)
                    {
                        _marketContract.addFutureToCCP(_clearingMemberAddress, askOrders[i].clearingMemberAddress, instrumentID, Utils.uintToString(_quantity), Utils.uintPriceToString(askOrders[i].price), settlementTimestamp, market);
                    }
                    else if (instType == Utils.instrumentType.swap)
                    {
                        //_marketContract.addSwapToCCP(_clearingMemberAddress, askOrders[i].clearingMemberAddress, instrumentID, Utils.uintToString(_quantity), Utils.uintPriceToString(askOrders[i].price), settlementTimestamp, market);
                    }

                    askOrders[i].quantity = askOrders[i].quantity - _quantity;
                    _quantity = 0;
                }
                i++;
            }
        }

        if (_quantity > 0)
        {
          addBidToOrderBook(_clearingMemberAddress, _quantity, _price);
        }
    }

    function addSellOrder(address _clearingMemberAddress, uint _quantity, uint _price) public onlyMarket
    {
        if (bidOrders.length != 0)
        {
            uint i = 0;
            Market _marketContract = Market(marketAddress);

            while (_price >= bidOrders[i].price && _quantity > 0)
            {
                if (_quantity >= bidOrders[i].quantity)
                {
                    if (instType == Utils.instrumentType.future)
                    {
                        _marketContract.addFutureToCCP(bidOrders[i].clearingMemberAddress, _clearingMemberAddress, instrumentID, Utils.uintToString(bidOrders[i].quantity), Utils.uintPriceToString(bidOrders[i].price), settlementTimestamp, market);
                    }
                    else if (instType == Utils.instrumentType.swap)
                    {
                        //_marketContract.addSwapToCCP(bidOrders[i].clearingMemberAddress, _clearingMemberAddress, instrumentID, Utils.uintToString(bidOrders[i].quantity), Utils.uintPriceToString(bidOrders[i].price), settlementTimestamp, market);
                    }

                    _quantity = _quantity - bidOrders[i].quantity;
                    Utils.removeOrder(bidOrders, i);
                    i--;
                }
                else
                {
                    if (instType == Utils.instrumentType.future)
                    {
                        _marketContract.addFutureToCCP(bidOrders[i].clearingMemberAddress, _clearingMemberAddress, instrumentID, Utils.uintToString(_quantity), Utils.uintPriceToString(bidOrders[i].price), settlementTimestamp, market);
                    }
                    else if (instType == Utils.instrumentType.swap)
                    {
                        //_marketContract.addSwapToCCP(bidOrders[i].clearingMemberAddress, _clearingMemberAddress, instrumentID, Utils.uintToString(_quantity), Utils.uintPriceToString(bidOrders[i].price), settlementTimestamp, market);
                    }
                    bidOrders[i].quantity = bidOrders[i].quantity - _quantity;
                    _quantity = 0;
                }
                i++;
            }
        }

        if (_quantity > 0)
        {
            addAskToOrderBook(_clearingMemberAddress, _quantity, _price);
        }
    }

    function addBidToOrderBook(address _clearingMemberAddress, uint _quantity, uint _price) internal
    {
        bidOrders.push(Utils.order(_clearingMemberAddress, _quantity, block.timestamp,  _price));
        orderDecreasing(bidOrders);
    }

    function addAskToOrderBook(address _clearingMemberAddress, uint _quantity, uint _price) internal
    {
        askOrders.push(Utils.order(_clearingMemberAddress, _quantity, block.timestamp,  _price));
        orderDecreasing(bidOrders);
    }
}

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
        //CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
        //_compensationChamber.addClearingMember(0xc9b6e6f423be49fe3f00f0be127d32831645561f);
        //_compensationChamber.addClearingMember(0xf6c718755ef2db32495e79967571bddba6c7836a);
        // End for test
    }

    event logPaymentRequest(address, uint, address, address);
    function paymentRequest(address _paymentRequestAddress) public onlyCCP
    {
        PaymentRequest _paymentRequestContract = PaymentRequest(_paymentRequestAddress);
        uint value = _paymentRequestContract.getValue();
        address clearingMember = _paymentRequestContract.getClearingMember();
        address creatorOfTheRequest = _paymentRequestContract.getOwner();
        logPaymentRequest(_paymentRequestAddress, value, clearingMember, creatorOfTheRequest);
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

contract MarketData is usingOraclize
{
  /**
   * To enable strings.sol library
   */
  using strings for *;


  event LogConstructorInitiated(string nextStep);
  event LogNewOraclizeQuery(string description);
  event returnCurrencyExchange(string currExchange);
  event returnETHPrice(string ethPrice);
  event callbackRuning(string log);

  mapping(bytes32 => uint) queryIdToFunctionNumber;
  mapping(bytes32 => address) queryIdToContractAddressThatHaveCalledTheFunction;

  function MarketData() public payable
  {
    LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
  }

  /**
   * The base coin can only be EUR, for other coins you neew a premium fixer.io account
   * _base and _secundary with ISO 4217
   * Function number 1
   */
  function getCurrencyExchange(string _base, string _secundary) public payable
  {
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
      string memory string1 = "json(http://data.fixer.io/api/latest?access_key=c06c3bdf5ea5e65c2dfb574f744725c4&base=";
      string memory string2 = _base;
      string memory string3 = "&symbols=";
      string memory string4 = _secundary;
      string memory string5 = ").rates.";

      string memory querys1 = strConcat(string1, string2, string3, string4);
      string memory query = strConcat(querys1, string5, string4);

      LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
      bytes32 queryID = oraclize_query("URL",query);
      queryIdToFunctionNumber[queryID] = 1;
    }
  }
  /**
   * Get the actual ETH price with respect to a currency
   * _baseCurrency ISO 4217
   * Function number 3
   */
  function getETHPrice(string _baseCurrency) public  payable
  {
    /**
     * this.balance is the number of ETH stored in the contract,
     * msg.value is the amount of ETH send to a public payable method
     */
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
        string memory URL = "json(https://api.kraken.com/0/public/Ticker?pair=ETH";
        string memory baseCurrency = _baseCurrency;
        string memory query1 = ").result.XETHZ";
        string memory query2 = ".c.0";

        string memory query = strConcat(URL, baseCurrency, query1,baseCurrency, query2);

        LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
        bytes32 queryID = oraclize_query("URL",query);
        queryIdToFunctionNumber[queryID] = 3;
    }
  }

  function getIMFutureBOE(string _nominal, string _instrumentID) public payable
  {
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
      string memory URL = "json(https://83.231.14.17:3002/BOE/computeVaR/";
      //string memory URL = "json(https://tidy-jellyfish-22.localtunnel.me/BOE/computeVaR/";
      string memory query1 = "0.95";
      string memory query2_4 = "/";
      //string memory query3 = _nominal;
      //string memory query5 = _instrumentID;
      string memory query6 = "/).*";

      string memory _query = strConcat(URL, query1, query2_4, _nominal, query2_4);
      string memory query = strConcat(_query, _instrumentID, query6);
      bytes32 queryID = oraclize_query("URL",query);
      queryIdToContractAddressThatHaveCalledTheFunction[queryID] = msg.sender;
      queryIdToFunctionNumber[queryID] = 4;
    }
  }

  function getIMFutureEUREX(string _nominal, string _instrumentID) public payable
  {
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
      string memory URL = "json(https://83.231.14.17:3002/EUREX/computeVaR/";
      string memory query1 = "0.95";
      string memory query2_4 = "/";
      //string memory query3 = _nominal;
      //string memory query5 = _instrumentID;
      string memory query6 = "/).*";

      string memory _query = strConcat(URL, query1, query2_4, _nominal, query2_4);
      string memory query = strConcat(_query, _instrumentID, query6);
      bytes32 queryID = oraclize_query("URL",query);
      queryIdToContractAddressThatHaveCalledTheFunction[queryID] = msg.sender;
      queryIdToFunctionNumber[queryID] = 4;
    }
  }

  function getIMFutureCME(string _nominal, string _instrumentID) public payable
  {
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
      string memory URL = "json(https://83.231.14.17:3002/CME/computeVaR/";
      string memory query1 = "0.95";
      string memory query2_4 = "/";
      //string memory query3 = _nominal;
      //string memory query5 = _instrumentID;
      string memory query6 = "/).*";

      string memory _query = strConcat(URL, query1, query2_4, _nominal, query2_4);
      string memory query = strConcat(_query, _instrumentID, query6);
      bytes32 queryID = oraclize_query("URL",query);
      queryIdToContractAddressThatHaveCalledTheFunction[queryID] = msg.sender;
      queryIdToFunctionNumber[queryID] = 4;
    }
  }


  function getIMSwap(string _nominal, string _instrumentID) public payable
  {
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
      string memory URL = "json(https://83.231.14.17:3002/BOE/computeVaR/";
      string memory query1 = "0.95";
      string memory query2_4 = "/";
      //string memory query3 = _nominal;
      //string memory query5 = _instrumentID;
      string memory query6 = "/).*";

      string memory _query = strConcat(URL, query1, query2_4, _nominal, query2_4);
      string memory query = strConcat(_query, _instrumentID, query6);
      //LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
      bytes32 queryID = oraclize_query("URL",query);
      queryIdToContractAddressThatHaveCalledTheFunction[queryID] = msg.sender;
      queryIdToFunctionNumber[queryID] = 4;
    }

  }

  function __callback(bytes32 myid, string result)
  {
  /*  if (msg.sender != oraclize_cbAddress())
    {
      revert();
    }
    callbackRuning("The callback is runing");
    uint functionNumber = queryIdToFunctionNumber[myid];

    if(functionNumber == 1)
    {
      returnCurrencyExchange(result);
    }
    else if(functionNumber == 2)
    {
      returnCurrencyExchange(result);
    }
    else if(functionNumber == 3)
    {
      returnETHPrice(result);
    }
    else if(functionNumber == 4)
    {*/

     address contractAddress = queryIdToContractAddressThatHaveCalledTheFunction[myid];
     Derivative _derivative = Derivative(contractAddress);
     //vanillaSwap _vanillaSwap = vanillaSwap(contractAddress);
     _derivative.setIM(result);
   // }
  }

}

contract PaymentRequest
{
    uint value;

    address owner;
    address clearingMemberAddress;

    function getValue() view public returns(uint)
    {
        return value;
    }

    function getClearingMember() view public returns(address)
    {
        return clearingMemberAddress;
    }

    function getOwner() view public returns(address)
    {
        return owner;
    }
}

contract CompensationChamber
{
    address private marketAddress;
    address private marketDataAddress;
    address private settlementAddress;

    mapping (address => bool) isAClearingMember;
    address[] clearingMembersAddresses;

    address[] payments;
    address[] derivatives;

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

    function CompensationChamber(uint timestampUntilNextVMrevision) public payable
    {
        marketAddress = msg.sender;
        marketDataAddress = (new MarketData).value(3 ether)();
        //uint timeUntilFirstVMRevisionInSeconds = timestampUntilNextVMrevision - block.timestamp;
    }

    function addClearingMember(address _clearingMemberAddress) onlyMarket public
    {
        clearingMembersAddresses.push(_clearingMemberAddress);
        isAClearingMember[_clearingMemberAddress] = true;
    }

    function futureNovation(address _longClearingMemberAddress, address _shortClearingMemberAddress, string _instrumentID, string _amount, string _price, uint _settlementTimestamp, string _market) public onlyMarket payable
    {
        bool _longClearingMemberAddressExist = isAClearingMember[_longClearingMemberAddress];
        bool _shortClearingMemberAddressExist = isAClearingMember[_shortClearingMemberAddress];

        require(_longClearingMemberAddressExist == true && _shortClearingMemberAddressExist == true && msg.value >= 1 ether);

        derivatives.push((new Future).value(msg.value)(_longClearingMemberAddress, _shortClearingMemberAddress, _instrumentID, _amount, _price, _settlementTimestamp, marketDataAddress, _market));
    }

    //function swapNovation(address _fixedLegClearingMemberAddress, address _floatingLegClearingMemberAddress, string _instrumentID, string _nominal, uint _settlementTimestamp, string _market) public payable

    function getMarketAddress() public view returns(address)
    {
        return marketAddress;
    }

    function paymentRequest() public
    {
        //payments.push(msg.sender);
        //Market _marketContract = Market(marketAddress);
       // _marketContract.paymentRequest(msg.sender);
    }
}

/**
 * Derivative is an abstract contract: Contracts are marked as abstract when at
 * least one of their functions lacks an implementation as in the following
 * example (note that the function declaration header is terminated by ;):
 */

contract Derivative
{
    string instrumentID;
    string market;

    address marketDataAddress;
    address compensationChamberAddress;

    uint tradeTimestamp;
    uint settlementTimestamp;

    string price;

    // initialMargin store the PaymentRequest address of the initial margin for both counterparts
    mapping (address => address) initialMargin;

    // variationMargin store the last PaymentRequest address of the variation margin for both counterparts
    // It is only stored the las one becaus if one counterpart don't each variation margin before the deadline the contract finishes

    mapping (address => address) variationMargin;
    // in this map it sores the accumulated variation margin that each counterpart have payed in the contract
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
     * Constructor
     */
    function Derivative(string _instrumentID, uint _settlementTimestamp, address _marketDataAddress, string _market, string _price) public
    {
        instrumentID = _instrumentID;
        market = _market;

        marketDataAddress = _marketDataAddress;
        compensationChamberAddress = msg.sender;
        price = _price;

        settlementTimestamp = _settlementTimestamp;
        tradeTimestamp = block.timestamp;
    }

    function getTheContractCounterparts() public returns(address[2]);

    function getInitialMarginPaymentRequestAddress(address _clearingMemberAddress) public view returns(address)
    {
        address initialMarginParmentRequestAddress = initialMargin[_clearingMemberAddress];

        if (initialMarginParmentRequestAddress != 0)
        {
            return initialMarginParmentRequestAddress;
        }
    }

    function getVariationMarginPaymentRequestAddress(address _clearingMemberAddress) public view returns(address)
    {
        address initialMarginParmentRequestAddress = initialMargin[_clearingMemberAddress];

        if (initialMarginParmentRequestAddress != 0)
        {
            return initialMarginParmentRequestAddress;
        }
    }

    function setIM(string result);

    function computeVM() public /*onlyChamber*/ returns (Utils.variationMarginChange[2]);

}

contract Future is Derivative
{
    address longMemberAddress; // The one who will have to buy the asset (subyacente) in the settlementTimestamp
    address shortMemberAddress; // The one who will have to sell the asset (subyacente) in the settlementTimestamp
    string amount; // Amount of the subyacent asset that they have to trade at settlementTimestamp

    function Future(address _longMemberAddress, address _shortMemberAddress, string _instrumentID, string _amount, string _price, uint _settlementTimestamp, address _marketDataAddress, string _market) Derivative(_instrumentID, _settlementTimestamp, _marketDataAddress, _market, _price) public payable
    {
        require (msg.value >= 1 ether);

        longMemberAddress = _longMemberAddress;
        shortMemberAddress = _shortMemberAddress;
        amount = _amount;
        computeIM();
    }

    function computeIM() private
    {
        MarketData marketDataContract = MarketData(marketDataAddress);

        if (Utils.compareStrings( market, "BOE")) // Bank of england
        {
          marketDataContract.getIMFutureBOE.value(1 ether)(amount, instrumentID);
        }
        else if (Utils.compareStrings(market, "EUREX")) // https://www.quandl.com/data/EUREX-EUREX-Futures-Data
        {
          marketDataContract.getIMFutureEUREX.value(1 ether)(amount, instrumentID);
        }
        else if (Utils.compareStrings(market, "CME"))// Chicago Mercantile Exchanges // https://www.quandl.com/data/CME-Chicago-Mercantile-Exchange-Futures-Data
        {
          marketDataContract.getIMFutureCME.value(1 ether)(amount, instrumentID);
        }
    }

    function setIM(string result) onlyMarketData public
    {
        initialMargin[longMemberAddress] = new PaymentRequest();
       // initialMargin[shortMemberAddress] = new PaymentRequest(100, shortMemberAddress, compensationChamberAddress, Utils.paymentType.initialMargin);
    }

    function computeVM() public /*onlyChamber*/ returns (Utils.variationMarginChange[2])
    {
        Utils.variationMarginChange[2] ret;
        ret[0] = Utils.variationMarginChange(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, 10);
        ret[1] = Utils.variationMarginChange(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, 10);
        return ret;
    }

    function getTheContractCounterparts() public returns(address[2])
    {
        return [longMemberAddress, shortMemberAddress];
    }
}
