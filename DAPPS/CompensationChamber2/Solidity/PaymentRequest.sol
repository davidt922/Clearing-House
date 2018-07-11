pragma solidity ^0.4.20;

import "Utils.sol";
import "CompensationChamber.sol";

contract PaymentRequest
{
    uint value;
    uint timestamp;
    bool payed;

    address owner;
    address clearingMemberAddress;
    address compensationChamberAddress;

    Utils.paymentType payType;

    function PaymentRequest(uint _value, address _clearingMemberAddress, address _compensationChamberAddress, Utils.paymentType _payType) public
    {
        value = _value;
        timestamp = block.timestamp;
        owner = msg.sender;
        payed = false;

        clearingMemberAddress = _clearingMemberAddress;
        compensationChamberAddress = _compensationChamberAddress;

        payType = _payType;

        CompensationChamber _compensationChamberContract = CompensationChamber(compensationChamberAddress);
        _compensationChamberContract.paymentRequest();
    }

    function pay() public payable returns(bool)
    {
        require (msg.value == value);
        payed = true;
        return payed;
    }

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
