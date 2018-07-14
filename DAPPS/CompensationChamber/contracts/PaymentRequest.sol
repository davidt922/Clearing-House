pragma solidity ^0.4.20;

import "./Utils.sol";
import "./CompensationChamber.sol";

/**
 * Add oraclize API
 */
import "installed_contracts/oraclize-api/contracts/usingOraclize.sol";

contract PaymentRequest
{
    uint value;
    uint payType;
    bool payed;

    address owner;
    address clearingMemberAddress;
    address compensationChamberAddress;

    function PaymentRequest(uint _value, address _clearingMemberAddress, address _compensationChamberAddress, uint _payType) public
    {
        owner = msg.sender;
        compensationChamberAddress = _compensationChamberAddress;
        clearingMemberAddress = _clearingMemberAddress;
        value = _value;
        payType = _payType;
        payed = false;
        CompensationChamber _compensationChamberContract = CompensationChamber(compensationChamberAddress);
        _compensationChamberContract.paymentRequest(value, clearingMemberAddress);
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

    function pay() public payable returns(bool)
    {
        require(msg.value == value);
        payed = true;

        return payed;
    }

    function isPayed() view public returns(bool)
    {
        return payed;
    }
}
