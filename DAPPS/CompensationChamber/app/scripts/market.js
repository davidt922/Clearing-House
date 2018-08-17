// Import the page's CSS. Webpack will know what to do with it.
import "../styles/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract';
import {BigNumber} from 'bignumber.js';
import OrderBook from './orderBook.js';


// Import our contract artifacts and turn them into usable abstractions.
import market_artifacts from '../../build/contracts/Market.json';

// Market is our usable abstraction, which we'll use thow the code below
var Market = contract(market_artifacts);

var accounts;
var account;

var instruments = [];

window.App = {

  start: function()
  {
    var self = this;

    // Bootstrap the MetaCoin abstraction for Use.
    Market.setProvider(web3.currentProvider);

    // Get the initial account balance so it can be displayed.
    web3.eth.getAccounts(function(err, accs)
    {
      if (err != null)
      {
        alert("There was an error fetching your accounts.");
        return;
      }

      if (accs.length == 0)
      {
        alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.");
        return;
      }

      accounts = accs;
      account = accounts[0];
    });


    // FICAR els events de Market que vull escolar

    Market.deployed().then(function(value)
    {
      var paymentRequestEvent = value.logPaymentRequest();

      paymentRequestEvent.watch(function(error, result)
      {
        if(!error)
        {
          console.log(result);
        }
      });

      var marketOrderEvent = value.logMarketOrder();

      marketOrderEvent.watch(function(error, result)
      {
        if (!error)
        {
          instruments[solOrderTx.args.instrumentID].order(result);
        }
      });
    });
  },

  addCompensationMember: function(_name, _email, _password)
  {
    var self = this;
    var _market;

    Market.deployed().then(function(instance)
    {
      _market = instance;
      return _market.addClearingMember(_name, _email, _password, {from: account, gas: 39000000});
    })
    .then(function(value)
    {
      console.log(value);
      //alert(value.logs[0].args.addressID);
      var addressID = new BigNumber(value.logs[0].args.addressID).toNumber();
      console.log(addressID);
      if (addressID == -1)
      {
        alert("This email is already registred");
      }
      else
      {
        account = accounts[addressID];
        _market.confirmClearingMemberAddress(_email, {from: account, gas: 39000000});
        alert("Your ethereum account public key is "+account);
        showLogin();
      }
    });
},

login: function (_email, _password)
{
  var self = this;
  var _market;

  Market.deployed().then(
    function(instance)
    {
      _market = instance;
      return _market.signIn.call(_email, _password, {from: accounts[2], gas: 39000000});
    })
    .then(function(value)
    {
      var errorCode = new BigNumber(value[2]).toNumber();
      var address = value[1];

      if (errorCode == -1)
      {
        alert("This email is not registred");
        return -1;
      }
      else if (errorCode == -2)
      {
        alert("The password is incorrect");
        return -1;
      }
      else
      {
         $("#index").remove();
         $("#main").show();
         account = address;
         setMarket();
      }
    });
},

  addOrderToBlockchain : function(_instrumentID, _type)
  {
    var _quantity = parseInt(document.getElementById("quantity").value);
    var _price = parseInt(document.getElementById("price").value);
    var _market;

    // _market.addOrder("IUDERB3",10, 10000, "SELL",{from: account, gas: 39000000});
    Market.deployed().then(function(instance)
      {
        _market = instance;
        return _market.addOrder(_instrumentID, _quantity, _price, _type, {from: account, gas: 39000000});
      }).then(function(value)
    {
      console.log(value);
    });
  }
};


window.setMarket = function()
{
  var _market;
  Market.deployed().then(function(instance)
  {
    // for testing
    _market = instance;
    return _market.addNewDerivative("IUDERB3", marketToInteger("BOE"), 0, 120003000,{from: account, gas: 39000000});
  }).then(function(value)
  {
    return _market.getInstruments({from: account, gas: 39000000});
  }).then(function(value)
  {
    var instrumentArray = value.logs;
    var _instrumentID;
    console.log(instrumentArray);
    for (var k = 0; k < instrumentArray.length; k++)
    {
      _instrumentID = web3.toUtf8(instrumentArray[k].args._instrumentID);
      instruments[_instrumentID] = new OrderBook(_instrumentID);
    }
  }).then(function(value)
  {
    _market.getMarket({from: account, gas: 39000000});
  });

}


window.marketToInteger = function(marketString)
{
  if (marketString == "BOE")
  {
    return 0;
  }
  else if (marketString == "EUREX")
  {
    return 1;
  }
  else if (marketString == "CME")
  {
    return 2;
  }
}
