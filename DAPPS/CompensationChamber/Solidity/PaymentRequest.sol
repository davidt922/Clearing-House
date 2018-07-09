pragma solidity ^0.4.20;

import "Utils.sol";

contract PaymentRequest //is Enums//is Utils// is Utils hi ha algo que no li agrada
{

  uint value; // value in wei
 // uint timestamp;
  bool payed;

  //address derivativeAddress;
  //address clearingMemberContractAddress;

//  paymentType payType;

  function PaymentRequest(uint _value, address _clearingMemberContractAddress, uint _type) public
  {
    value = _value;
    //timestamp = block.timestamp;
    //derivativeAddress = msg.sender;
    //payed = false;

    //clearingMemberContractAddress = _clearingMemberContractAddress;

   /* if (_type == 0)
    {
        payType = paymentType.initialMargin;
    }
    else if (_type == 1)
    {
        payType = paymentType.variationMargin;
    }*/
    //ClearingMember _clearingMember = ClearingMember(clearingMemberContractAddress);
    //_clearingMember.paymentRequest();
  }

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
}

contract Test
{
    address owner;
    function Test() public
    {
        owner = msg.sender;
    }
}
