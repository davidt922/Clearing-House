// Import the page's CSS. Webpack will know what to do with it.
import "../stylesheets/app.css";

// Import libraries we need.
import { default as Web3} from 'web3';
import { default as contract } from 'truffle-contract';
import {BigNumber} from 'bignumber.js';

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
      var paymentRequestEvent = value.logPaymentRequestAddress();

      paymentRequestEvent.watch(function(error, result)
      {
        if(!error)
        {
          console.log(result);
        }
      });

      var marketOrderEvent = value.logMarketoorder();

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
      alert(value.logs[0].args.getString);
      var addressID = new BigNumber(value.logs[1].args.addressID).toNumber();

      if (addressID != -1)
      {
        account = accounts[addressID];
        alert("Your ethereum account public key is "+account);
        _market.confirmClearingMemberAddress(_email, {from: account, gas: 39000000});
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
      var addressID = new BigNumber(value[0]).toNumber();
      var name = value[1];

      if (addressID == -1)
      {
        alert("This email is not registred");
        return -1;
      }
      else if (addressID == -2)
      {
        alert("The password is incorrect");
        return -1;
      }
      else
      {
         $("#index").remove();
         $("#main").show();
         account = accounts[addressID];
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

function setMarket()
{
  var _market;
  Market.deployed().then(function(instance)
  {
    // for testing
    _market = instance;
    return _market.addNewDerivative("IUDERB3", "BOE", 0, 120003000,{from: account, gas: 39000000});
  }).then(function(value)
  {
    return _market.getInstruments({from: account, gas: 39000000});
  }).then(function(value)
  {
    var instrumentArray = value.logs;
    var _instrumentID;

    for (var k = 0; k < instrumentArray.length; k++)
    {
      _instrumentID = instrumentArray[k].args.instrumentID;
      instruments[_instrumentID] = new OrderBook(_instrumentID);
    }
  }).then(function(value)
  {
    _market.getMarket({from: account, gas: 39000000});
  });

}
