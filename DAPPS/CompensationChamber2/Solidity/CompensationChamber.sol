pragma experimental ABIEncoderV2;

import "Market.sol";
import "Utils.sol";
import "Future.sol";

contract CompensationChamber
{
    address private marketAddress;
    address private marketDataAddress;
    address private settlementAddress;

    mapping (address => bool) isAClearingMember;
    address[] clearingMembersAddresses;

    address[] payments;
    address[] derivatives;

    /**
     * Modifiers
     */

    modifier onlyMarket
    {
        require(msg.sender == marketAddress);
        _;
    }

    modifier onlySettlement
    {
        require(msg.sender == settlementAddress);
        _;
    }

    modifier onlyMarketData
    {
        require(msg.sender == marketDataAddress);
        _;
    }

    function CompensationChamber(uint timestampUntilNextVMrevision) public payable
    {
        marketAddress = msg.sender;
        marketDataAddress = (new MarketData).value(3 ether)();
        uint timeUntilFirstVMRevisionInSeconds = timestampUntilNextVMrevision - block.timestamp;
    }

    function addClearingMember(address _clearingMemberAddress) onlyMarket public
    {
        clearingMembersAddresses.push(_clearingMemberAddress);
        isAClearingMember[_clearingMemberAddress] = true;
    }

    function futureNovation(address _longClearingMemberAddress, address _shortClearingMemberAddress, string _instrumentID, string _amount, string _price, uint _settlementTimestamp, string _market) public onlyMarket payable
    {
        bool _longClearingMemberAddressExist = isAClearingMember[_longClearingMemberAddress];
        bool _shortClearingMemberAddressExist = isAClearingMember[_shortClearingMemberAddress];

        require(_longClearingMemberAddressExist == true && _shortClearingMemberAddressExist == true && msg.value >= 1 ether);

        derivatives.push((new Future).value(msg.value)(_longClearingMemberAddress, _shortClearingMemberAddress, _instrumentID, _amount, _price, _settlementTimestamp, marketDataAddress, _market));
    }

    //function swapNovation(address _fixedLegClearingMemberAddress, address _floatingLegClearingMemberAddress, string _instrumentID, string _nominal, uint _settlementTimestamp, string _market) public payable

    function getMarketAddress() public view returns(address)
    {
        return marketAddress;
    }

    function paymentRequest() public
    {
        payments.push(msg.sender);
        Market _marketContract = Market(marketAddress);
        _marketContract.paymentRequest(msg.sender);
    }
}
