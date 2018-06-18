pragma solidity ^0.4.18;

contract future
{
  bytes3 currency; // ISO_4217 only 3 digits to define a currency
  uint maturityDate;
  bytes16 ISIN;
}

contract option
{

}

contract call is option
{

}

contract put is option
{

}

contract compensationChamber
{
  address private owner;
  address private marketAddress;

  uint private nextRevisionTime;
  uint private nextPaymentTime;

  event clearingMemberInfo(address _memberAddress);

  mapping (address => clearingMember) clearingMemberMap;
  address[] public clearingMemberArray;

  struct clearingMember
  {
    address memberAddress;
    future[] futures;
    option[] options;
  }

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
    marketAddress = _marketAddress;
  }

  function addClearingMember(address _clearingMemberAddress) onlyChamber public
  {
    clearingMember storage newClearingMember = clearingMemberMap[_clearingMemberAddress];
    newClearingMember.memberAddress = _clearingMemberAddress;
    emit clearingMemberInfo(_clearingMemberAddress);
  }




}
