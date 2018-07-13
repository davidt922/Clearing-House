pragma solidity ^0.4.20;

import "Utils.sol";
import "CompensationChamber.sol";

/**
 * Add oraclize API
 */
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract PaymentRequest is usingOraclize
{
    uint value;
    uint payType;
    bool payed;

    address owner;
    address clearingMemberAddress;
    address compensationChamberAddress;

    function PaymentRequest(uint _value, address _clearingMemberAddress, address _compensationChamberAddress, uint _payType) public payable
    {
        owner = msg.sender;
        compensationChamberAddress = _compensationChamberAddress;
        clearingMemberAddress = _clearingMemberAddress;
        value = _value;
        payType = _payType;
        payed = false;
       // CompensationChamber _compensationChamberContract = CompensationChamber(compensationChamberAddress);
       // _compensationChamberContract.paymentRequest(value, clearingMemberAddress);

        oraclize_query(60, "URL", "json(https://api.nasa.gov/planetary/apod?api_key=NNKOjkoul8n1CH18TWA9gwngW1s1SmjESPjNoUFo).copyright");

    }

    function getValue() public payable returns(uint)
    {
        return value;
    }

    function getClearingMember() public payable returns(address)
    {
        return clearingMemberAddress;
    }

    function getOwner() public payable returns(address)
    {
        return owner;
    }

    function pay() public payable returns(bool)
    {
        require(msg.value == value);
        payed = true;

        return payed;
    }

    function isPayed() public payable returns(bool)
    {
        return payed;
    }
    event done(string)
    function __callback(bytes32 myid, string result)
    {
        if (msg.sender != oraclize_cbAddress())
        {
            revert();
        }

        if (payed == false)
        {
            CompensationChamber _compensationChamberContract = CompensationChamber(compensationChamberAddress);
            _compensationChamberContract.deleteClearingMember(clearingMemberAddress);
        }
        done("DONE");
    }
}
