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

// Import libraries we need.
$('.message a').click(function()
{
   $('form').animate({height: "toggle", opacity: "toggle"}, "slow");
});

function showLogin()
{
  $('.register-form').hide();
  $('.login-form').show();
}

function showRegister()
{
  $('.register-form').show();
  $('.login-form').hide();
}


$(document).ready(function ()
{
        showLogin();
        $('#register').click(function ()
        {
            showLogin();
        });
        $('#login').click(function ()
        {
          showRegister();
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

    //FICAR els events de market que vull escolar

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
}).then(function(value){
  return _market.getInstruments({from: account, gas: 39000000});
}).then(function(value){

  if (value != -1)
  {
    var instrumentArray = value.logs;
    var _instrumentID;

    for (var k = 0; k < instrumentArray.length; k++)
    {
      _instrumentID = instrumentArray[k].args.instrumentID;
      instruments[_instrumentID] = new OrderBook(_instrumentID);
    }
    return 0;
  }
  else
  {
      return -1;
  }

}).then(function(value)
  {
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
    var marketOrderEvent = _market.logMarketOrder();

    marketOrderEvent.watch(function(error, result)
    {
      if(!error)
      {
        console.log(result);
        var args = result.args;
        var price = new BigNumber(args.price).toNumber();
        var quantity = new BigNumber(args.quantity).toNumber();
        console.log("order "+args.instrumentID+" price "+price+" quantity"+quantity+" side"+args.side);
        instruments[args.instrumentID].addOrder(price, quantity, args.side);
      }
    });
    /*
      if (value != 0)
      {
          var _orders = value.logs;
          console.log(_orders);
          var order;
          var quantity;
          var price;
          for (var k = 0; k < _orders.length; k++)
          {
            order = _orders[k].args;
            //test();
            //orders.push({instrumentID: _orders[k].instrumentID, quantity: new BigNumber(_orders[k].quantity).toNumber(), price: })
            price = new BigNumber(order.price).toNumber();
            quantity = new BigNumber(order.quantity).toNumber();
            instruments[order.instrumentID].addOrder(price, quantity, order.side);

          }
      }*/
  })
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

class OrderBook
{
/*  this.ask = [];
  this.bid = [];*/

  constructor(instrumentID)
  {
    this.instrumentID = instrumentID;
    addOrderToHTML(instrumentID);
    this.ask = [];
    this.bid = [];
  }

  addOrder(_price, _quantity, _side)
  {
    //orders.push({price: _price, quantity: _quantity});
    if (_side == "ASK")
    {
      this.addAskOrder(_price, _quantity);
    }
    else if (_side == "BID")
    {
      this.addBidOrder(_price, _quantity);
    }
  }

  addAskOrder(_price, _quantity)
  {
    // if there is another order with this price
    var found = this.ask.find(function(element)
    {
        return element.price = _price;
    });

    if (found != undefined)
    {
      found.quantity = found.quantity + _quantity;
    }
    else
    {
      this.ask.push({price: _price, quantity: _quantity});
    }
    this.updateOrderBook();
  }

  addBidOrder(_price, _quantity)
  {
    var found = this.bid.find(function(element)
    {
        return element.price = _price;
    });

    if (found != undefined)
    {
      found.quantity = found.quantity + _quantity;
    }
    else
    {
      this.bid.push({price: _price, quantity: _quantity});
    }
    this.updateOrderBook();
  }

  removeAskOrder(_price, _quantity)
  {

  }

  removeBidOrder(_price, _quantity)
  {

  }

  updateOrderBook()
  {
    //$("#table"+this.instrumentID+" tbody").empty();

    this.updateAskOrderBook();
    this.updateBidOrderBook();
  }

  updateAskOrderBook()
  {
    if (this.ask.length > 0)
    {
      this.ask.sort(function(a,b) {return (a.price > b.price) ? 1 : ((b.price > a.price) ? -1 : 0);} );

      var j = this.ask.length > 4 ? 3 : this.ask.length - 1;

      for (var i = j ; i>=0; i--)
      {
        $("#table"+this.instrumentID).find('tbody').append("<tr> <td></td> <td>"+this.ask[i].price+"</td> <td>"+this.ask[i].quantity+"</td> </tr>");
      }
    }
  }

  updateBidOrderBook()
  {
    if (this.bid.length > 0)
    {
      this.bid.sort(function(a,b) {return (a.price < b.price) ? 1 : ((b.price < a.price) ? -1 : 0);} );

      var j = this.bid.length > 4 ? 4 : this.bid.length;
      console.log(this.bid);
      for (var i = 0; i<j; i++)
      {
        $("#table"+this.instrumentID).find('tbody').append("<tr> <td>"+this.bid[i].quantity+"</td> <td>"+this.bid[i].price+"</td> <td></td> </tr>");
      }
    }
  }
}

function addOrderToHTML(instrumentID)
{
  $( "#orderBooks" ).append("<div class='orderBook'><div>"+instrumentID.toUpperCase()+"</div><div class='orders' id='orders"+instrumentID+"'></div><div><button class='twoButtons' id='buy"+instrumentID+"'>BUY</button><button class='twoButtons' style='background:#ff0000;' id='sell"+instrumentID+"'>SELL</button></div></div>");
  $("#orders"+instrumentID).append("<table id='table"+instrumentID+"'><thead><tr><th>Bid Size</th><th>Price</th><th>Ask Size</th></tr></thead><tbody></tbody></table>");

  $("#buy"+instrumentID).click(function()
  {
    createDialog(instrumentID, "Buy");
  });
  $("#sell"+instrumentID).click(function()
  {
    createDialog(instrumentID, "Sell");
  });
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

  document.getElementById("buttonID").addEventListener("click", function()
  {
    var _market;
    Market.deployed().then(function(instance)
    {
      _market = instance;
      return _market.getMarket({from: account, gas: 39000000})
    })
    .then(function(value)
    {
      var _args;
      console.log(value.logs.length);

      for(var k = 0; k < value.logs.length; k++)
      {
        _args = value.logs[k].args;
        console.log(_args.instrumentID+" "+_args.side+" "+_args.quantity+" "+_args.price);
      }
    });
  });

});


function createDialog(instrumentID, side)
{
  if (side == "Buy")
  {
    dialog.dialog({  title: side+" "+instrumentID }).dialog({buttons:
      {
        Buy: function()
        {
          App.addOrderToBlockchain(instrumentID, "BUY");
          dialog.dialog( "close" );
        },
        Cancel: function()
        {
          dialog.dialog( "close" );
        }
      }}).dialog( "open" );
  }
  else if(side == "Sell")
  {
    dialog.dialog({  title: side+" "+instrumentID }).dialog({buttons:
      {
        Sell: function(callback)
        {
          //console.log(callback);
          App.addOrderToBlockchain(instrumentID, "SELL");
          dialog.dialog( "close" );
        },
        Cancel: function()
        {
          dialog.dialog( "close" );
        }
      }}).dialog( "open" );
  }
}

var dialog;
$( function() {
   var  form;

     // From http://www.whatwg.org/specs/web-apps/current-work/multipage/states-of-the-type-attribute.html#e-mail-state-%28type=email%29
   dialog = $( "#dialog-form" ).dialog({
     autoOpen: false,
     height: 400,
     width: 350,
     modal: true,
     buttons:
     {
       //"Create an account": addUser,
       Cancel: function()
       {
         dialog.dialog( "close" );
       }
     },
     close: function()
     {
       form[ 0 ].reset();
     }
   });

   form = dialog.find( "form" ).on( "submit", function( event ) {
     event.preventDefault();
     addUser();
   });

   $( "#create-user" ).button().on( "click", function() {
     dialog.dialog( "open" );
   });
 } );
