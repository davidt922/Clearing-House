/******************************************************************************/
/******************************* CLEARING MEMBER ******************************/
/******************************************************************************/

contract clearingMember is Utils
{
  /**
   * Clearing member address
   * Compensation Chamber address
   * Array of addresses corresponding to the contracts that this clearing member have
   */
  address private memberAddress;
  address[] private derivates;
  address[] private payments;
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

  function addDerivate(address _initialMarginPaymentAddress) public
  {
    derivates.push(msg.sender);
    derivate _newDerivate = derivate(msg.sender);
    payments.push(_initialMarginPaymentAddress);

    Payment _newPayment = Payment(_initialMarginPaymentAddress);
    //uint memory initialmarginValue = _newPayment.getValue();

    CompensationChamber _compensationChamber = CompensationChamber(chamberAddress);

    //_compensationChamber.sendInitialMarginRequest(msg.sender);

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
