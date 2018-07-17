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
    mapping (string => bool) emailIsRegistred;
    mapping (string => Utils.clearingMember) mapEmailToClearingMemberStruct;
    address[] clearingMembersAddresses;
    Utils.clearingMember[] clearingMembers;

    address[] payments;
    address[] derivatives;

    int numberOfClearingMembers;

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
        numberOfClearingMembers = 0;
        //uint timeUntilFirstVMRevisionInSeconds = timestampUntilNextVMrevision - block.timestamp;
    }

    function addClearingMember(string _name, string _email, address _clearingMemberAddress, string _password) onlyMarket public returns(int)
    {

        if (emailIsRegistred[_email] == true)
        {
          return -1;
        }
        else
        {
          numberOfClearingMembers++;
          int addressID = numberOfClearingMembers;

          isAClearingMember[_clearingMemberAddress] = true;
          emailIsRegistred[_email] = true;
          Utils.clearingMember memory _clearingMemberStruct = Utils.clearingMember(_name, _email, 0x0, _password, addressID);
          mapEmailToClearingMemberStruct[_email] = _clearingMemberStruct;
          clearingMembers.push(_clearingMemberStruct);
          clearingMembersAddresses.push(_clearingMemberAddress);

          return addressID;
        }
    }

    function confirmClearingMember(address _clearingMemberAddress, string _email)
    {
      if (isAClearingMember[_clearingMemberAddress] != true)
      {
        isAClearingMember[_clearingMemberAddress] = true;
        mapEmailToClearingMemberStruct[_email].clearingMemberAddress = _clearingMemberAddress;
      }
    }

    function checkSignInEmailAndPassword(string _email, string _password) onlyMarket public returns(int addressID, string name, address clearingMemberAddress)
    {
      if (emailIsRegistred[_email] != true)
      {
        addressID = -1;
        name = "";
        clearingMemberAddress = 0x0;
      }
      else if (Utils.compareStrings(mapEmailToClearingMemberStruct[_email].password, _password))
      {
        addressID = mapEmailToClearingMemberStruct[_email].addressID;
        name = mapEmailToClearingMemberStruct[_email].name;
        clearingMemberAddress = mapEmailToClearingMemberStruct[_email].clearingMemberAddress;
      }
      else
      {
        addressID = -2;
        name = "";
        clearingMemberAddress = 0x0;
      }
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
