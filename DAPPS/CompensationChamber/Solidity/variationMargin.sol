contract variationMargin is usingOraclize
{
  /**
   * To enable strings.sol library
   */
  using strings for *;


  event LogConstructorInitiated(string nextStep);
  event LogNewOraclizeQuery(string description);
  event returnCurrencyExchange(string currExchange);
  event returnETHPrice(string ethPrice);
  event callbackRuning(string log);

  mapping(bytes32 => uint) queryIdToFunctionNumber;
  mapping(bytes32 => address) queryIdToContractAddressThatHaveCalledTheFunction;

  function variationMargin() public payable
  {
    LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
  }

  /**
   * The base coin can only be EUR, for other coins you neew a premium fixer.io account
   * _base and _secundary with ISO 4217
   * Function number 1
   */

  function computeVM(address[] arrayOfAssets) public payable
  {
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
        for(uint i = 0; i<arrayOfAssets.length; i++)
        {
            asset _asset = asset(arrayOfAssets[i]);

        }
      //string memory URL = "json(http://83.231.14.17:3001/BOE/computeVaR/";
      //string memory query1 = "0.95";
      //string memory query2_4 = "/";
      //string memory query3 = _nominal;
      //string memory query5 = _instrumentID;
      //string memory query6 = "/).*";

      //string memory _query = strConcat(URL, query1, query2_4, _nominal, query2_4);
      //string memory query = strConcat(_query, _instrumentID, query6);
      //LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
      //bytes32 queryID = oraclize_query("URL",query);
      //queryIdToContractAddressThatHaveCalledTheFunction[queryID] = msg.sender;
      //queryIdToFunctionNumber[queryID] = 4;
    }

  }

  function __callback(bytes32 myid, string result)
  {
    if (msg.sender != oraclize_cbAddress())
    {
      revert();
    }
    callbackRuning("The callback is runing");
    address _assetAddress = queryIdToContractAddressThatHaveCalledTheFunction[myid];
    asset _asset = asset(_assetAddress);
    _asset.setVM(result); 
  }
}
