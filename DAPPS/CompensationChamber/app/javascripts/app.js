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

var orders = [];


// Import libraries we need.
$('.message a').click(function()
{
   $('form').animate({height: "toggle", opacity: "toggle"}, "slow");
});

$(document).ready(function () {

        $('.register-form').hide();
        $('.login-form').show();

        $('#register').click(function () {
            $('.register-form').hide();
            $('.login-form').show
            ();
        });
        $('#login').click(function () {
            $('.register-form').show();
            $('.login-form').hide();
        });
    });

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

      //self.refreshBalance();
    });
  },

  addCompensationMember: function(_name, _email, _password)
  {
    var self = this;
    var _market;
    console.log("js functrion addCompensationMember executed");

    Market.deployed().then(function(instance)
    {
      _market = instance;
      console.log("Execute add clearing member");
      return _market.addClearingMember(_name, _email, _password, {from: account, gas: 39000000});
    }).then(function(value)
  {
    alert(value.logs[0].args.getString);
    console.log(value.logs[1].args.addressID);
    var addressID = new BigNumber(value.logs[1].args.addressID).toNumber();
    console.log(addressID);
    account = accounts[addressID];
    console.log(account);
    _market.confirmClearingMemberAddress(_email, {from: account, gas: 39000000});
  })
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
    account = value[2];


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
      //alert("Welcome "+name+"!")
       $("#index").remove();
       $("#main").show();
       account = accounts[addressID];
       return 0;
    }
  }).then(function(value)
{
  console.log(value);
  if (value == 0)
  {
    return _market.addNewDerivative("IUDERB3", "BOE", 0, 120003000,{from: account, gas: 39000000});
  }
  else
  {
    return -1;
  }
}).then(function(value)
{
  console.log(value);
    if (value != -1)
    {
      return _market.addOrder("IUDERB3",10, 10000, "SELL",{from: account, gas: 39000000});
    }
    else
    {
      return -1;
    }
})
  .then(function(value)
  {
    console.log(value);
      if (value != -1)
      {
        return _market.getMarket({from: account, gas: 39000000})
      }
      else
      {
        return 0;
      }
  }).then(function(value)
  {
      if (value != 0)
      {
          console.log(value.logs);
          var _orders = value.logs;

          for (var k = 0; k < _orders.length; k++)
          {
            //test();
            //orders.push({instrumentID: _orders[k].instrumentID, quantity: new BigNumber(_orders[k].quantity).toNumber(), price: })
          }
          var a = new OrderBook("TELEFONICA");
          a.addOrder(11,22);
          var b = new OrderBook("Repsol");
      }
  })
}
/*
*/
/*
  setStatus: function(message)
  {
    var status = document.getElementById("status");
    status.innerHTML = message;
  },
  refreshBalance: function()
  {
    var self = this;
    var meta;
    MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.getBalance.call(account, {from: account});
    }).then(function(value) {
      var balance_element = document.getElementById("balance");
      balance_element.innerHTML = value.valueOf();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error getting balance; see log.");
    });
  },
  sendCoin: function()
  {
    var self = this;
    var amount = parseInt(document.getElementById("amount").value);
    var receiver = document.getElementById("receiver").value;
    this.setStatus("Initiating transaction... (please wait)");
    var meta;
    MetaCoin.deployed().then(function(instance) {
      meta = instance;
      return meta.sendCoin(receiver, amount, {from: account});
    }).then(function() {
      self.setStatus("Transaction complete!");
      self.refreshBalance();
    }).catch(function(e) {
      console.log(e);
      self.setStatus("Error sending coin; see log.");
    });
  }*/
};

class OrderBook
{
  constructor(instrumentID)
  {
    this.instrumentID = instrumentID;
    addOrderToHTML(instrumentID);
  }
  addOrder(_price, _quantity)
  {
    orders.push({price: _price, quantity: _quantity});
    $("#orders"+this.instrumentID).append("<div>"+_price+" "+_quantity+"</div>");
  }
}

function addOrderToHTML(instrumentID)
{
  $( "#orderBooks" ).append("<div class='orderBook'><div class='orders' id='orders"+instrumentID+"'></div><div><button class='twoButtons'>BUY</button><button class='twoButtons' style='background:#ff0000;'>SELL</button></div></div>");
}

window.addEventListener('load', function()
{
  // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined')
  {
    console.warn("Using web3 detected from external source. If you find that your accounts don't appear or you have 0 MetaCoin, ensure you've configured that source properly. If using MetaMask, see the following link. Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask")
    // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider);
  }
  else
  {
    console.warn("No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live, as it's inherently insecure. Consider switching to Metamask for development. More info here: http://truffleframework.com/tutorials/truffle-and-metamask");
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider("http://127.0.0.1:8545"));
  }

  App.start();
  console.log("Is market deployed:");
  console.log(Market.deployed());

  document.getElementById("create").addEventListener("click", function()
  {
    var name = document.getElementById("name1").value;
    var email = document.getElementById("email1").value;
    var password = document.getElementById("password1").value;
      App.addCompensationMember(name, email, password);
  }, false);

  document.getElementById("loginButton").addEventListener("click", function()
  {
    var email = document.getElementById("email2").value;
    var password = document.getElementById("password2").value;
     App.login(email, password);
  });
});
