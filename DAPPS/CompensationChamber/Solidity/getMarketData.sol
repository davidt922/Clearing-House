pragma solidity ^0.4.18;

/*
* Add oraclize api used for call a function every 24h and to obtain data from external sources
* For example, obtain data from marker
*
*/
import "github.com/oraclize/ethereum-api/oraclizeAPI.sol";

contract MarketData is usingOraclize
{
  string currencyPar;
  string querys1;
  string querys2;

  string price;
      event LogConstructorInitiated(string nextStep);
    event LogPriceUpdated(string price);
    event LogNewOraclizeQuery(string description);
    event returnCurrencyExchange(string currExchange);

  function MarketData() public payable
  {
    LogConstructorInitiated("Constructor was initiated. Call 'updatePrice()' to send the Oraclize Query.");
  }
  // The base coin can only be EUR, for other coins you neew a premium fixer.io account
  function getCurrencyExchange(string _base, string _secundary) public  payable
  {
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
      string memory string1 = "json(http://data.fixer.io/api/latest?access_key=c06c3bdf5ea5e65c2dfb574f744725c4&base=";

      string memory string2 = _base;

      string memory string3 = "&symbols=";

      string memory string4 = _secundary;

      string memory string5 = ").rates.";

      querys1 = strConcat(string1, string2, string3, string4);
      querys2 = strConcat(querys1, string5, string4);

      currencyPar = strConcat(_base,"/",_secundary);

      LogNewOraclizeQuery("Oraclize query was sent, standing by for the answer..");
      oraclize_query("URL",querys2);
    }
  }
  function uintToString(uint v) private constant returns (string str) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(48 + remainder);
        }
        bytes memory s = new bytes(i + 1);
        for (uint j = 0; j <= i; j++) {
            s[j] = reversed[i - j];
        }
        str = string(s);
    }

  function get5yMarketData(string _stockSymbol) public  payable
  {
    if (oraclize_getPrice("URL") > this.balance)
    {
      LogNewOraclizeQuery("Oraclize query was NOT sent, please add some ETH to cover for the query fee");
    }
    else
    {
      /*string memory string1 = "json(https://api.iextrading.com/1.0/stock/";

      string memory string2 = _stockSymbol;

      string memory string3 = "/chart/5y";

      string memory string4 = ").";

      string memory firstPart = strConcat(string1, string2, string3, string4);

      for (uint i = 0; i < 10; i++)
      {
        string memory string5 = uintToString(i);
        querys1 = strConcat(firstPart, string5,".vwap");
        oraclize_query("URL",querys1);
      }*/
      string memory string1 = "json(https://api.iextrading.com/1.0/stock/aapl/chart/)";
      oraclize_query("URL",querys2);
    }

  }

  function __callback(bytes32 myid, string result)
  {
    if (msg.sender != oraclize_cbAddress()) revert();

    string memory ret = strConcat(currencyPar,": ",result);
    returnCurrencyExchange(ret);
  }
}
