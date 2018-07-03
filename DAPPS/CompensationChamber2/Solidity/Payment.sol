


contract Payment
{
  uint value; // value in wei
  uint timestamp;
  bool payed;

  address derivativeAddress;
  address clearingMemberContractAddress;
  address paymentsAddress;

  paymentType payType;

  enum paymentType
  {
    initialMargin,
    variationMargin
  }

  function Payment(uint _value, address _derivativeAddress, address _clearingMemberContractAddress, uint _type) public
  {
    value = _value;
    timestamp = block.timestamp;
    derivativeAddress = _derivativeAddress;
    payed = false;
    paymentsAddress = msg.sender;

    clearingMemberContractAddress = _clearingMemberContractAddress;

    if (type == 0)
    {
      payType = paymentType.initialMargin;
    }
    else if(type == 1)
    {
      payType = paymentType.variationMargin;
    }
    CompensationChamber _compensationChamber = CompensationChamber()

  }

  function pay() payable
  {
    require(msg.value == value);
    payed = true;
    Payments _payments = Payments(paymentsAddress);
    _payments.payed();
  }
  function getValue() public returns(uint)
  {
    return value;
  }
}
