pragma experimental ABIEncoderV2;

import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";
import "github.com/Arachnid/solidity-stringutils/strings.sol";

import "Utils.sol";

/**
 * Derivative is an abstract contract: Contracts are marked as abstract when at
 * least one of their functions lacks an implementation as in the following
 * example (note that the function declaration header is terminated by ;):
 */

contract Derivative
{
    string instrumentID;
    string market;

    address marketDataAddress;
    address compensationChamberAddress;

    uint tradeTimestamp;
    uint settlementTimestamp;

    string price;

    // initialMargin store the PaymentRequest address of the initial margin for both counterparts
    mapping (address => address) initialMargin;

    // variationMargin store the last PaymentRequest address of the variation margin for both counterparts
    // It is only stored the las one becaus if one counterpart don't each variation margin before the deadline the contract finishes

    mapping (address => address) variationMargin;
    // in this map it sores the accumulated variation margin that each counterpart have payed in the contract
    mapping(address => uint) accumulatedVariationMargin;

    /**
     * Modifiers
     */

    modifier onlyMarketData
    {
        require(msg.sender == marketDataAddress);
        _;
    }

    modifier onlyChamber
    {
        require(msg.sender == compensationChamberAddress);
        _;
    }

    /**
     * Constructor
     */
    function Derivative(string _instrumentID, uint _settlementTimestamp, address _marketDataAddress, string _market, string _price) public
    {
        instrumentID = _instrumentID;
        market = _market;

        marketDataAddress = _marketDataAddress;
        compensationChamberAddress = msg.sender;
        price = _price;

        settlementTimestamp = _settlementTimestamp;
        tradeTimestamp = block.timestamp;
    }

    function getTheContractCounterparts() public returns(address[2]);

    function getInitialMarginPaymentRequestAddress(address _clearingMemberAddress) public view returns(address)
    {
        address initialMarginParmentRequestAddress = initialMargin[_clearingMemberAddress];

        if (initialMarginParmentRequestAddress != 0)
        {
            return initialMarginParmentRequestAddress;
        }
    }

    function getVariationMarginPaymentRequestAddress(address _clearingMemberAddress) public view returns(address)
    {
        address initialMarginParmentRequestAddress = initialMargin[_clearingMemberAddress];

        if (initialMarginParmentRequestAddress != 0)
        {
            return initialMarginParmentRequestAddress;
        }
    }

    function setIM(string result);

    function computeVM() public returns (Utils.variationMarginChange[2]);

}
