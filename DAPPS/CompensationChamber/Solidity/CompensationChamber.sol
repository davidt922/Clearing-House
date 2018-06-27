pragma solidity ^0.4.18;

/**
 * Add oraclize api used for call a function every 24h and to obtain data from external sources
 */
import "./lib/oraclizeAPI.sol";
/**
 * We will only have one instance of this contract, that will represent the compensation compensationChamber
 * All the contracts will be created using this one
 */
import "./MarketData.sol";
import "./vanillaSwap.sol";
import "./lib/strings.sol";

contract compensationChamber
{
  event inicialMargin(string a);
  /**
   * Constants
   */
  uint private dayInSeconds = 86400; // Number of seconds in 24 h

  /**
   * From the moment that the CCP indicates the daily collateral that both counterparts
   * Have to send to the chamber, they have 12 hours to pay it.
   */
  uint private timeToPayTheMargin = 43200;

  /**
   * Address of the compensation chamber and the market
   */
  address private owner;
  address private marketAddress;
  address private marketDataAddress;

  /**
   * Timestamp in seconds since epox indicating the date and time when the chamber will do the
   * next asset valuation and will infrom of the daily marginal that the counterparts have to give to the chamber.
   * Or to liquidate the operation if the contract has reached the maturity date.
   */
  uint private nextRevisionTime;
  uint private deadlineForMarginalPayment;
  bool private marketAddressChange = true;

  /**
   * Map an Ethereum account address with the corresponding clearing member contract address
   */
  mapping (address => address) mapEtherAccountToContractAddress;
  address[] clearingMembersAddresses;
  address[] clearingMemberContractAddresses;
  address[] assets;

  function compensationChamber() public payable
  {
    owner = msg.sender;
    nextRevisionTime = block.timestamp + dayInSeconds;
    deadlineForMarginalPayment = nextRevisionTime + timeToPayTheMargin;
    marketDataAddress = (new MarketData).value(5 ether)();
  }

  function getMarketDataAddress() public payable returns(address)
  {
      return marketDataAddress;
  }


  /**
   * Create the modifiers, this is a pattern that restricts the execution of some functions, read the content of modify the contract
   * also allows to perfom timed transactions
   */
  modifier onlyChamber
  {
    require(msg.sender == owner);
    _;
  }
  modifier onlyMarket
  {
    require(msg.sender == marketAddress);
    _;
  }

  /**
   * Add functions of the smartcontract
   */
  function setMarketAddress(address _marketAddress) onlyChamber public payable
  {
    require(marketAddressChange);
    marketAddressChange = false;
    marketAddress = _marketAddress;
  }

  function addClearingMember(address _clearingMemberAddress) onlyChamber public payable
  {
    address contractAddress = mapEtherAccountToContractAddress[_clearingMemberAddress];

    /**
     * if the contract address is 0, means that he address conrresponds to a new clearing member
     * so a new clearingMember contract have to be created.
     * if the contract exist, revert the changes and send an error message
     */
    if(contractAddress == 0)
    {
      mapEtherAccountToContractAddress[_clearingMemberAddress] = new clearingMember(_clearingMemberAddress);
      clearingMembersAddresses.push(_clearingMemberAddress);
      clearingMemberContractAddresses.push(mapEtherAccountToContractAddress[_clearingMemberAddress]);
    }
    else
    {
      //revert("There is a contract of a liquidator member linked to this address");
    }
  }

  function getDeadlineForMarginalPayment() public payable returns(uint)
  {
    return deadlineForMarginalPayment;
  }

  function getClearingMemberAddresses() public payable returns(address[])
  {
      return clearingMembersAddresses;
  }
  function getContractForAGivenAddress(address _clearingMemberAddress) public payable returns(address)
  {
      return mapEtherAccountToContractAddress[_clearingMemberAddress];
  }


  /**
   * Products
   */
  function addVanillaSwap(address _floatingLegMemberAddress, address _fixedLegMemberAddress, uint _settlementDate, string _nominal, string _instrumentID) /*onlyMarket */payable public
  {
    assets.push( (new vanillaSwap).value(10 ether)(marketDataAddress, mapEtherAccountToContractAddress[_floatingLegMemberAddress], mapEtherAccountToContractAddress[_fixedLegMemberAddress], _settlementDate, _nominal, _instrumentID));
  }
}
