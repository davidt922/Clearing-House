pragma experimental ABIEncoderV2;

import "./Market.sol";
import "./Utils.sol";
import "./Future.sol";
import "./VariationMarginAutoExecution.sol";

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
        require (msg.sender == marketAddress);
        _;
    }

    modifier onlySettlement
    {
        require (msg.sender == settlementAddress);
        _;
    }

    modifier onlyMarketData
    {
        require (msg.sender == marketDataAddress);
        _;
    }

    modifier onlyVMOrMarket
    {
        require (msg.sender == marketAddress/* || msg.sender == */);
        _;
    }

    function CompensationChamber(uint timestampUntilNextVMrevision) public payable
    {
        marketAddress = msg.sender;
        marketDataAddress = (new MarketData).value(3 ether)();
        //uint timeUntilFirstVMRevisionInSeconds = timestampUntilNextVMrevision - block.timestamp;
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

    function paymentRequest(uint _value, address _clearingMemberAddress) public
    {
        payments.push(msg.sender);
        Market _marketContract = Market(marketAddress);
        _marketContract.paymentRequest(msg.sender, _value, _clearingMemberAddress);
    }


    // Compute
    uint counter;
    mapping (address => uint) mapAddressToTotalVM;

    function computeVariationMargin() /*onlyVMOrMarket*/ public
    {
        counter = derivatives.length * 2;
        Utils.variationMarginChange[2] memory varMarginChangeArray;

        for (uint i = 0; i < derivatives.length; i++)
        {
            Derivative _derivative = Derivative(derivatives[i]);
            varMarginChangeArray = _derivative.computeVM();

            variationMargin(varMarginChangeArray[0]);
            variationMargin(varMarginChangeArray[1]);
        }
    }

    mapping (address => int) mapAddressToVMValue;

    function variationMargin(Utils.variationMarginChange _VMStruct) private
    {
        counter = counter - 1;

        mapAddressToVMValue[_VMStruct.clearingMemberAddress] = mapAddressToVMValue[_VMStruct.clearingMemberAddress] + _VMStruct.value;

        if (counter == 0)
        {
            sendPaymentRequestOrSendPayment();
            removeMapAddressToVMValue();
        }
    }

    function sendPaymentRequestOrSendPayment() private
    {
        int value;
        address clearingMemberAddress;

        address paymentRequestAddress;

        for (uint i = 0; i < clearingMembersAddresses.length; i++)
        {
            clearingMemberAddress = clearingMembersAddresses[i];
            value = mapAddressToVMValue[clearingMemberAddress];

            if (value > 0)
            {
                paymentRequestAddress = new PaymentRequest( uint(value), clearingMemberAddress, this, 1);
            }
            else if (value < 0)
            {
                clearingMemberAddress.transfer( uint(value/-1));
            }
        }
    }

    function removeMapAddressToVMValue() private
    {
        for (uint i = 0; i < clearingMembersAddresses.length; i++)
        {
            mapAddressToVMValue[clearingMembersAddresses[i]] = 0;
        }
    }
}
