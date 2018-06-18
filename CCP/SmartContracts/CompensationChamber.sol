pragma solidity ^0.4.18;

contract future
{
  bytes32 futureId;
  bytes3 currency; // ISO_4217 only 3 digits to define a currency
  uint maturityDate;
  bytes16 ISIN;
  bool optionPosition; // Sell or buy
}

contract option
{
  bytes3 currency; // ISO_4217 only 3 digits to define a currency
  uint maturityDate;
  bytes16 ISIN;
}

contract call is option
{

}

contract put is option
{

}

contract clearingMember
{
  address private memberAddress;
  future[] private futures;
  option[] private options;
  int private strike = 0;
  address private chamberAddress;

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

  constructor(address _clearingMemberAddress)
  {
    memberAddress = _clearingMemberAddress;
  }

  function addFuture(future _future) onlyChamber public
  {
    futures.push(_future);
  }

  function addOption(option _option) onlyChamber public
  {
    options.push(_option);
  }

}

contract compensationChamber
{
  /* Constants */
  uint private aDayInSeconds = 86400; // 24 h
  uint private incrementOfTimeToPayTheMargin = 43200;  // 12 h

  /* Compensation Chamber Variables */
  address private owner;
  address private marketAddress;

  uint private nextRevisionTime;
  uint private nextPaymentTime;
  bool private marketAddressChange = true;

  event clearingMemberInfo(address _memberAddress);

  mapping (address => clearingMember) public clearingMemberMap;
  address[] public clearingMemberArray;

  constructor() public
  {
    owner = msg.sender;
  }

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

  function setMarketAddress(address _marketAddress) onlyChamber public
  {
    require(marketAddressChange);
    marketAddressChange = false;
    marketAddress = _marketAddress;
  }

  function addClearingMember(address _clearingMemberAddress) onlyChamber public
  {
    clearingMemberMap[_clearingMemberAddress] = new clearingMember(_clearingMemberAddress);
    emit clearingMemberInfo(_clearingMemberAddress);
  }

  function addFuture(address _buyerAddress, address _sellerAddress, bytes16 _ISIN, bytes3 currency, uint _maturityDate) onlyMarket public payable
  {
    require(msg.value == 0.2 ether);
    clearingMember buyer = clearingMemberMap[_buyerAddress];
    clearingMember seller = clearingMemberMap[_buyerAddress];

  }

  function getNextPaymentTime() public constant returns(uint)
  {
      return nextPaymentTime;
  }



}
