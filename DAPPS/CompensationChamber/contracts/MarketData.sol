pragma solidity ^0.4.24;

import "./usingOraclize.sol";
/**
 * Allow Slice strings
 */
import "./strings.sol";

import "./Utils.sol";


contract MarketData is usingOraclize
{
  mapping(bytes32 => uint16) queryIdToFunctionNumber;
  mapping(bytes32 => address) queryIdToContractAddressThatHaveCalledTheFunction;

  address compensationChamberAddress;

  uint gasLimit = 4000000;
  constructor() public payable
  {
    OAR = OraclizeAddrResolverI(0x6f485c8bf6fc43ea212e93bbf8ce046c7f1cb475);
    compensationChamberAddress = msg.sender;
  }

  function getIMFutureBOE (bytes32 _nominalBytes32, bytes32 _instrumentIDBytes32) public payable
  {
    if (oraclize_getPrice("URL") < this.balance)
    {
      string memory _nominal = Utils.bytes32ToString(_nominalBytes32);
      string memory _instrumentID = Utils.bytes32ToString(_instrumentIDBytes32);

      string memory URL = "json(https://83.231.14.17:3002/BOE/computeVaR/";
      //string memory URL = "json(https://tidy-jellyfish-22.localtunnel.me/BOE/computeVaR/";
      string memory query1 = "0.95";
      string memory query2_4 = "/";
      string memory query6 = "/).*";

      string memory _query = strConcat(URL, query1, query2_4, _nominal, query2_4);
      string memory query = strConcat(_query, _instrumentID, query6);
      bytes32 queryID = oraclize_query("URL",query, gasLimit);
      queryIdToContractAddressThatHaveCalledTheFunction[queryID] = msg.sender;
      queryIdToFunctionNumber[queryID] = 1;
    }
  }

  function getIMFutureEUREX (bytes32 _nominalBytes32, bytes32 _instrumentIDBytes32) public payable
  {
    if (oraclize_getPrice("URL") < this.balance)
    {
      string memory _nominal = Utils.bytes32ToString(_nominalBytes32);
      string memory _instrumentID = Utils.bytes32ToString(_instrumentIDBytes32);

      string memory URL = "json(https://83.231.14.17:3002/EUREX/computeVaR/";
      string memory query1 = "0.95";
      string memory query2_4 = "/";
      string memory query6 = "/).*";

      string memory _query = strConcat(URL, query1, query2_4, _nominal, query2_4);
      string memory query = strConcat(_query, _instrumentID, query6);
      bytes32 queryID = oraclize_query("URL",query, gasLimit);
      queryIdToContractAddressThatHaveCalledTheFunction[queryID] = msg.sender;
      queryIdToFunctionNumber[queryID] = 1;
    }
  }

  function getIMFutureCME (bytes32 _nominalBytes32, bytes32 _instrumentIDBytes32) public payable
  {
    if (oraclize_getPrice("URL") < this.balance)
    {
      string memory _nominal = Utils.bytes32ToString(_nominalBytes32);
      string memory _instrumentID = Utils.bytes32ToString(_instrumentIDBytes32);

      string memory URL = "json(https://83.231.14.17:3002/CME/computeVaR/";
      string memory query1 = "0.95";
      string memory query2_4 = "/";
      string memory query6 = "/).*";

      string memory _query = strConcat(URL, query1, query2_4, _nominal, query2_4);
      string memory query = strConcat(_query, _instrumentID, query6);
      bytes32 queryID = oraclize_query("URL",query, gasLimit);
      queryIdToContractAddressThatHaveCalledTheFunction[queryID] = msg.sender;
      queryIdToFunctionNumber[queryID] = 1;
    }
  }

  function __callback (bytes32 myid, string result)
  {
    if (msg.sender != oraclize_cbAddress())
    {
      revert();
    }
    uint16 functionNumber = queryIdToFunctionNumber[myid];

    if (functionNumber == 1)
    {
      // invocar Derivative
    }
  }
}
