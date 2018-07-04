pragma experimental ABIEncoderV2;

import "ClearingMember.sol";
import "Utils.sol";

contract PaymentRequest is Utils
{
  uint value; // value in wei
  uint timestamp;
  bool payed;

  address derivativeAddress;
  address clearingMemberContractAddress;
  //address paymentsAddress;

  paymentType payType;

  function PaymentRequest(uint _value, address _clearingMemberContractAddress, paymentType _type) public
  {
    value = _value;
    timestamp = block.timestamp;
    derivativeAddress = msg.sender;
    payed = false;

    clearingMemberContractAddress = _clearingMemberContractAddress;

    payType = _type;
    //ClearingMember _clearingMember = ClearingMember(clearingMemberContractAddress);
    //_clearingMember.paymentRequest();
  }

  function pay() payable returns(bool)
  {
    require(msg.value == value);
    payed = true;

    return payed;
  }
  function getValue() public returns(uint)
  {
    return value;
  }
}
