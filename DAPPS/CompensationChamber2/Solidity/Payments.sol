
/**
* 2 payment contracts will be deployed for each derivative, one for each member.
* inside they will hold all the payments that the member have to do related to the contract
*/
/*
contract Payments is Utils
{

  address derivativeAddress;
  address compensationChamberAddress;
  address clearingMemberAddress;

  enum paymentType
  {
    initialMargin,
    variationMargin
  }

  address[] allPayments;
  address[] unpayedPayments;

  function Payments(address _clearingMemberAddress, address _compensationChamberAddress, uint _initialMargin)
  {
    clearingMemberAddress = _clearingMemberAddress;
    compensationChamberAddress = _compensationChamberAddress;
    derivativeAddress = msg.sender;

    allPayments.push(new Payment(_initialMargin, _compensationChamberAddress, derivativeAddress, 0));
    unpayedPayments.push(new Payment(_initialMargin, _compensationChamberAddress, derivativeAddress, 0));
  }
  function payed() public
  {
    removeAddress(unpayedPayments,
  }
}
*/
