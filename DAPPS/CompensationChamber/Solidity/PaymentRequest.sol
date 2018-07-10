pragma solidity ^0.4.20;

import "Utils.sol";
//import "CompensationChamber.sol";

contract PaymentRequest is Enums//is Utils// is Utils hi ha algo que no li agrada
{

  uint value; // value in wei
  uint timestamp;
  bool payed;

  address owner;
  address clearingMemberContractAddress;
  address compensationChamberAddress;

  paymentType payType;

  function PaymentRequest(uint _value, address _clearingMemberContractAddress, paymentType _type) public
  {
    value = _value;
    timestamp = block.timestamp;
    owner = msg.sender;
    payed = false;

    clearingMemberContractAddress = _clearingMemberContractAddress;
    payType = _type;

    if (payType == paymentType.initialMargin)
    {

    }
    else if (payType == paymentType.variationMargin)
    {

        //CompensationChamber _compensationChamber = CompensationChamber(owner);
        // _compensationChamber.sendPaymentRequestToMarketParamContractAddress(clearingMemberContractAddress);
    }
    //ClearingMember _clearingMember = ClearingMember(clearingMemberContractAddress);
    //_clearingMember.paymentRequest();
  }
/*
  function PaymentRequest(uint _value, address _clearingMemberContractAddress) public
  {
    value = _value;
    timestamp = block.timestamp;
    compensationChamberAddress = msg.sender;
    payed = false;

    clearingMemberContractAddress = _clearingMemberContractAddress;
    payType = paymentType.variationMargin;

    //CompensationChamber _compensationChamber = CompensationChamber(compensationChamberAddress);
   // _compensationChamber.sendPaymentRequestToMarketParamContractAddress(clearingMemberContractAddress);
  }
*/
  function pay() public payable returns(bool)
  {
    require(msg.value == value);
    payed = true;

    return payed;
  }

  function getValue() view public returns(uint)
  {
    return value;
  }

  function getClearingMember() view public returns(address)
  {
      return clearingMemberContractAddress;
  }
}
