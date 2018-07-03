pragma solidity ^0.4.18;


import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";


/******************************************************************************/
/******************************* CONVERSIONS **********************************/
/******************************************************************************/

contract conversions
{
  using strings for *;

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

  // Convert string to uint
  function stringToUint(string s) constant returns (uint result)
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

  // convert string of this type: [aa, bb, cc] to an array of bytes32 ["aa","bb","cc"]
  function stringToBytes32Array2(string result) internal pure returns (bytes32[2] memory)
  {
    // Posible improve here
    var stringToParse = result.toSlice();
    stringToParse.beyond("[".toSlice()).until("]".toSlice()); //remove [ and ]
    var delim = ",".toSlice();
    //var parts = new string[](stringToParse.count(delim) + 1);
    bytes32[2] memory parts;
    for (uint i = 0; i < parts.length; i++)
    {
        parts[i] = stringToBytes32(stringToParse.split(delim).toString());
    }
    // Finish possible improve
    return parts;
  }

  // convert string of this type: [aa, bb, cc] to an array of uint ["aa","bb","cc"]
  function stringToUIntArray2(string result) internal returns (uint[2] memory)
  {
    // Posible improve here
    var stringToParse = result.toSlice();
    stringToParse.beyond("[".toSlice()).until("]".toSlice()); //remove [ and ]
    var delim = ",".toSlice();
    //var parts = new string[](stringToParse.count(delim) + 1);
    uint[2] memory parts;
    for (uint i = 0; i < parts.length; i++)
    {
        parts[i] = stringToUint(stringToParse.split(delim).toString());
    }
    // Finish possible improve
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
/*
  function remove(uint[] arrauint index)  returns(uint[])
  {
    if (index >= array.length) return;

    for (uint i = index; i<array.length-1; i++)
    {
        array[i] = array[i+1];
    }

    delete array[array.length-1];
    array.length--;
    return array;
  }
*/
}

/******************************************************************************/
/**************************** COMPENSATION CHAMBER ****************************/
/******************************************************************************/

contract compensationChamber is conversions
{
  using strings for *;

  event inicialMargin(address a, string b);
  event logString(string a);
  /**
   * Constants
   */
  uint private dayInSeconds = 86400; // Number of seconds in 24 h

  /**
   * From the moment that the CCP indicates the daily collateral that both counterparts
   * Have to send to the chamber, they have 12 hours to pay it.
   */
  uint private timeToPayTheMargin = 43200;

  /**
   * Address of the compensation chamber and the market
   */
  address private owner;
  address private marketAddress;
  address private marketDataAddress;

  /**
   * Timestamp in seconds since epox indicating the date and time when the chamber will do the
   * next future valuation and will infrom of the daily marginal that the counterparts have to give to the chamber.
   * Or to liquidate the operation if the contract has reached the maturity date.
   */
  uint private nextRevisionTime;
  uint private deadlineForMarginalPayment;
  bool private marketAddressChange = true;

  /**
   * Map an Ethereum account address with the corresponding clearing member contract address
   */
  mapping (address => address) mapEtherAccountToContractAddress;
  mapping (address => address) mapContractAddressToEtherAccount;
  address[] clearingMembersAddresses;
  address[] clearingMemberContractAddresses;
  address[] futures;

  function compensationChamber() public payable
  {
    owner = msg.sender;
    nextRevisionTime = block.timestamp + dayInSeconds;
    deadlineForMarginalPayment = nextRevisionTime + timeToPayTheMargin;
    marketDataAddress = (new MarketData).value(5 ether)();
  }

  function getMarketDataAddress() public payable returns(address)
  {
      return marketDataAddress;
  }


  /**
   * Create the modifiers, this is a pattern that restricts the execution of some functions, read the content of modify the contract
   * also allows to perfom timed transactions
   */
  modifier onlyChamber
  {
    require(msg.sender == owner);
    _;
  }
  modifier onlyMarket
  {
    require(msg.sender == marketAddress);
    _;
  }

  /**
   * Add functions of the smartcontract
   */
  function setMarketAddress(address _marketAddress) onlyChamber public payable
  {
    require(marketAddressChange);
    marketAddressChange = false;
    marketAddress = _marketAddress;
  }

  function addClearingMember(address _clearingMemberAddress) onlyChamber public payable
  {
    address contractAddress = mapEtherAccountToContractAddress[_clearingMemberAddress];

    /**
     * if the contract address is 0, means that he address conrresponds to a new clearing member
     * so a new clearingMember contract have to be created.
     * if the contract exist, revert the changes and send an error message
     */
    if(contractAddress == 0)
    {
      mapEtherAccountToContractAddress[_clearingMemberAddress] = new clearingMember(_clearingMemberAddress);
      mapContractAddressToEtherAccount[mapEtherAccountToContractAddress[_clearingMemberAddress]] = _clearingMemberAddress;
      clearingMembersAddresses.push(_clearingMemberAddress);
      clearingMemberContractAddresses.push(mapEtherAccountToContractAddress[_clearingMemberAddress]);
    }
    else
    {
      //revert("There is a contract of a liquidator member linked to this address");
    }
  }

  function getDeadlineForMarginalPayment() public payable returns(uint)
  {
    return deadlineForMarginalPayment;
  }

  function getClearingMemberAddresses() public payable returns(address[])
  {
      return clearingMembersAddresses;
  }
  function getContractForAGivenAddress(address _clearingMemberAddress) public payable returns(address)
  {
      return mapEtherAccountToContractAddress[_clearingMemberAddress];
  }

  function sendInitialMarginInformation(bytes32 _initialMargin) public
  {
    string memory initialMarginStr = bytes32ToString(_initialMargin);

    inicialMargin(mapContractAddressToEtherAccount[msg.sender], initialMarginStr);
  }

  function log(string a) public
  {
      logString(a);
  }

  function computeVariationMargin() public payable
  {

  }

  function sendVariationMarginInformation() public
  {
    future _future = future(msg.sender);
    _future;
  }


  /**
   * Products
   */
//  function addVanillaSwap(address _floatingLegMemberAddress, address _fixedLegMemberAddress, uint _settlementDate, string _nominal, string _instrumentID) /*onlyMarket */payable public
 // {
 //   futures.push( (new vanillaSwap).value(10 ether)(marketDataAddress, mapEtherAccountToContractAddress[_floatingLegMemberAddress], mapEtherAccountToContractAddress[_fixedLegMemberAddress], _settlementDate, _nominal, _instrumentID));
 // }
}

/******************************************************************************/
/********************************* DERIVATES **********************************/
/******************************************************************************/

contract derivate is conversions
{
  using strings for *;

  string instrumentID;

  address marketDataAddress;
  address compensationChamberAddress;

  uint tradeTimestamp;
  uint settlementTimestamp;

  /**
   * Map the contractAddresses to the value of initial margin they have to pay
   */
  mapping(address => uint) initialMargin;
  /**
   * Map the contractAddresses to the value of variation margin they have to pay
   * these value change every day
   */
  mapping(address => uint) variationMargin;

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

  function derivate(string _instrumentID, uint _settlementTimestamp, address _marketDataAddress) public
  {
    instrumentID = _instrumentID;

    marketDataAddress = _marketDataAddress;
    compensationChamberAddress = msg.sender;

    settlementTimestamp = _settlementTimestamp;
    tradeTimestamp = block.timestamp;
  }

  function getIM() public returns(uint)
  {
      return initialMargin[msg.sender];
  }
  function getIM(address _contractAddress) public returns(uint)
  {
    return initialMargin[_contractAddress];
  }

  function getVM() public returns(uint)
  {
    return variationMargin[msg.sender];
  }
  function getVM(address _contractAddress) public returns(uint)
  {
    return variationMargin[_contractAddress];
  }

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

  function payVM() public payable
  {

  }
}





/******************************************************************************/
/*********************************** FUTURES **********************************/
/******************************************************************************/


contract future is derivate
{
  address longMemberAddress; // The one who will have to buy the asset (subyacente) in the settlementTimestamp at the sett
  address shortMemberAddress; // The one who will have to sell the asset (subyacente) in the settlementTimestamp
  string amount; // Ammount of the subyacent asset that they have to trade at settlementTimestamp

  function future(address _longMemberAddress, address _shortMemberAddress, string _instrumentID, string _amount, uint _settlementTimestamp, address _marketDataAddress,string  market) derivate(_instrumentID, _settlementTimestamp, _marketDataAddress) public payable
  {
    longMemberAddress = _longMemberAddress; //floating leg
    shortMemberAddress = _shortMemberAddress; //fixed leg

    amount = _amount;

    variationMargin[_longMemberAddress] = 0;
    variationMargin[_shortMemberAddress] = 0;

    initialMargin[_longMemberAddress] = 0;
    initialMargin[_shortMemberAddress] = 0;

    computeIM(market);
  }

  function getClearingMemberContractAddressOfTheFuture() public onlyChamber returns(address[2])
  {
    return [longMemberAddress, shortMemberAddress];
  }

  function computeIM(string _market) public
  {
    MarketData marketDataContract = MarketData(marketDataAddress);

   // if(equals( _market, "BOE") ) // Bank of england
  //  {
      //marketDataContract.getIMFutureBOE.value(2 ether)(_nominal, _instrumentID);
  //  }
   // else if( _market == "EUREX" ) // https://www.quandl.com/data/EUREX-EUREX-Futures-Data
  //  {
      //marketDataContract.getIMFutureEUREX.value(2 ether)(_nominal, _instrumentID);
  //  }
  //  else if( _market == "CME" )// Chicago Mercantile Exchanges // https://www.quandl.com/data/CME-Chicago-Mercantile-Exchange-Futures-Data
  //  {
      //marketDataContract.getIMFutureCME.value(2 ether)(_nominal, _instrumentID);
   // }

  }

  function setIM(string result) onlyMarketData public
  {

    uint[2] memory parts = stringToUIntArray2(result); // first value = longMemberAddress, second value = shortMemberAddress

    initialMargin[longMemberAddress] = parts[0];
    initialMargin[shortMemberAddress] = parts[1];


    clearingMember clearingMember1 = clearingMember(longMemberAddress);
    clearingMember clearingMember2 = clearingMember(shortMemberAddress);

    clearingMember1.addDerivate();
    clearingMember2.addDerivate();

    compensationChamber _compensationChamber = compensationChamber(compensationChamberAddress);

    /*

    compensationChamber _compensationChamber = compensationChamber(compensationChamberAddress);
    initialMargin[contractAddress1] = parts[0];
    initialMargin[contractAddress2] = parts[1];

    clearingMember1.addFuture(initialMargin[contractAddress1]);
    clearingMember2.addFuture(initialMargin[contractAddress2]);*/
  }

  function setVM()
  {

  }

  function getTheContractCounterparts() public returns(address[2])
  {
    return [longMemberAddress, shortMemberAddress];
  }
}

/******************************************************************************/
/************************************* SWAP ***********************************/
/******************************************************************************/

contract swap is derivate
{
  address fixedLegMemberAddress; // The one who will have to buy the asset (subyacente) in the settlementTimestamp at the sett
  address floatingLegMemberAddress; // The one who will have to sell the asset (subyacente) in the settlementTimestamp
}

/******************************************************************************/
/*********************************** FORWARD **********************************/
/******************************************************************************/

contract forward is derivate
{

}



/******************************************************************************/
/********************************* VANILLA SWAP *******************************/
/******************************************************************************/

/*
contract vanillaSwap is swap
{

  function vanillaSwap(address _marketDataAddress, address _floatingLegMemberContractAddress, address _fixedLegMemberContractAddress, uint _settlementDate, string _nominal, string _instrumentID)swap(_marketDataAddress, _floatingLegMemberContractAddress, _fixedLegMemberContractAddress, _settlementDate, _nominal) public payable
  {
    MarketData marketDataContract = MarketData(_marketDataAddress);
    marketDataContract.getIMSwap.value(2 ether)(_nominal, _instrumentID);
  }

  function setVariationMargin() view onlyChamber public
  {
    MarketData marketDataContract = MarketData(marketDataAddress);
    //marketDataContract.getVMSwap.value(2 ether)(_nominal, _instrumentID);
  }

}*/

/******************************************************************************/
/******************************* CLEARING MEMBER ******************************/
/******************************************************************************/

contract clearingMember is conversions
{
  /**
   * Clearing member address
   * Compensation Chamber address
   * Array of addresses corresponding to the contracts that this clearing member have
   */
  address private memberAddress;
  address[] private derivates;
  address private chamberAddress;

  /**
   * Events
   */
  event initialMargin(string price);
  /**
   * Add modifiers for this contract, one for the chamber and the other for the clearing memeber
   */
  modifier onlyChamber
  {
    require(msg.sender == chamberAddress);
    _;
  }

  modifier onlyMember
  {
    require(msg.sender == memberAddress);
    _;
  }

  function clearingMember(address _clearingMemberAddress) public
  {
    memberAddress = _clearingMemberAddress;
    chamberAddress = msg.sender;
  }

  function addDerivate() public
  {
    derivates.push(msg.sender);
    derivate _newDerivate = derivate(msg.sender);
  }

  function payIM(address derivateAddress) public /*onlyMember*/ payable
  {
    derivate _newDerivate = derivate(msg.sender);
    _newDerivate.payIM.value(msg.value)();
  }
  function getDerivates() public returns(address[])
  {
      return derivates;
  }

  function getInitialMargin(address futureAddress) public view returns(uint)
  {
    future _future = future(futureAddress);
    return _future.getIM();
  }
}


/******************************************************************************/
/********************************* MARKET DATA ********************************/
/******************************************************************************/


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
    if (msg.sender != oraclize_cbAddress())
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
    {

     /*address contractAddress = queryIdToContractAddressThatHaveCalledTheFunction[myid];
     vanillaSwap _vanillaSwap = vanillaSwap(contractAddress);
     _vanillaSwap.setIM(result);*/
    }
  }

}
