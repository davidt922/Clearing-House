var express = require('express');
var request = require('request');
var app = express();

/******************************************************************************/

app.listen(3000, function()
{
  console.log("app.js listening on port 3000!")
});
/**
 * The Portfolio class will contain the portfolio of a Member
 * once inserted all the instruments intro the class, we can calculate the var.
 */

/******************************************************************************/
/********************************* PORTFOLIO **********************************/
/******************************************************************************/
"use strict"
function Portfolio()
{
  this.instrumentArray = [];
  this.portfolioDailyRentability = [];
}
/**
 * Method to add new instruments to the portfolio, each instrument will be an object containing an historical data
 * Of this instrument, and how many assets of this type have the Member
 */

"use strict"
Portfolio.prototype.addInstrument = function(instrument)
{
  this.instrumentArray.push(instrument);
}

"use strict"
Portfolio.prototype.computeVaR = function(probability)
{
  probability = 1 - probability;

  var historicalDataLength = this.instrumentArray[0].historicalRentability.length;

  for( var i = 0; i < historicalDataLength; i++ )
  {
    var _rentability = 0;

    for( var j = 0; j < this.instrumentArray.length; j++ )
    {
      _rentability = _rentability + this.instrumentArray[j].getRentability(i);
    }

    this.portfolioDailyRentability.push(_rentability);
  }

  this.portfolioDailyRentability.sort(function(a,b){return a - b});

  var VaRPosition = parseInt(this.portfolioDailyRentability.length * probability);

  return this.portfolioDailyRentability[VaRPosition];
}

/******************************************************************************/
/********************************* INSTRUMENT *********************************/
/******************************************************************************/

"use strict"
function Instrument(instrumentID, numberOfShares)
{
  this.historicalRentability = [];
  this.instrumentID = instrumentID;
  this.numberOfShares = numberOfShares;
}

"use strict"
Instrument.prototype.setInstrumentPrice = function(_instrumentPrice)
{
  this.instrumentPrice = _instrumentPrice;
}

"use strict"
Instrument.prototype.getRentability = function(day)
{
  return this.numberOfShares * this.instrumentPrice * this.historicalRentability[day];
}

"use strict"
Instrument.prototype.getInstrumentID = function()
{
  return this.instrumentID;
}

"use strict"
Instrument.prototype.setHistoricalRentability = function(_rentability)
{
  this.historicalRentability.push(_rentability);
}

/******************************************************************************/
/******************************* Interest Rate ********************************/
/******************************************************************************/

function InterestRate(_instrumentID, _nominal)
{
  this.instrumentID = _instrumentID;
  this.nominal = _nominal;
  this.historicalInterestRateChange = [];
}

InterestRate.prototype.setActualInterestRate = function(_interestRate)
{
  this.actualInterestRate = _interestRate;
}

InterestRate.prototype.setHistoricalInterestRateChange = function(_interestRate)
{
  this.historicalInterestRateChange.push(_interestRate);
}

InterestRate.prototype.getInstrumentID = function()
{
  return this.instrumentID;
}

InterestRate.prototype.computeVaR = function(probability)
{
  probability = 1 - probability;
  dataLength = this.historicalInterestRateChange.length;

  var escenarios = [];

  for (var i = 0; i < dataLength; i++)
  {
    escenarios.push(this.nominal * this.actualInterestRate * this.historicalInterestRateChange[i]);
  }
  escenarios.sort(function(a,b){return a - b});

  var VaRPosition = parseInt(escenarios.length * probability);
  return escenarios[VaRPosition];
}

/******************************************************************************/
/********************************** Get Date **********************************/
/******************************************************************************/

function getDate(y, m, d)
{
  var today = new Date();
  var dd = today.getDate();
  var mm = today.getMonth()+1; //January is 0!
  var yyyy = today.getFullYear();

  if(dd<10)
  {
      dd = '0'+dd
  }

  if(mm<10)
  {
      mm = '0'+mm
  }
  yyyy = yyyy - y;
  mm = mm - m;
  dd = dd - d;

  var todayDate = yyyy + "-" + mm + "-" + dd;
  return todayDate;
}

/******************************************************************************/
/********************************** Server ************************************/
/******************************************************************************/

app.get("/", function(req, res)
{
  res.send("This is the Main page of the server to compute Initial Margins and Variation Margins <br>")
});

/**
 * This function performs the historical VaR calculation
 *
 * @param probability is the VaR probability expressed in parts per unit
 * @param portfolio are the financial instruments id followed by an `-` and the number of assets that the member have of this instrument
 *
 */
app.get("/computeVaR/:probability/:portfolio", function(req, res)
{
  var portfolio = req.params.portfolio;
  var probability = req.params.probability;
  var portfolioSplit = portfolio.split("-");

  var assetsArray = [];

  var portfolioObject = new Portfolio();

  for( var i = 0; i < portfolioSplit.length; i = i + 2)
  {
    assetsArray.push(new Instrument(portfolioSplit[i], parseInt(portfolioSplit[i+1])));
  }

  var k = 0;
  for( var i = 0; i < assetsArray.length; i++ )
  {
    var url = "https://api.iextrading.com/1.0/stock/"+assetsArray[i].getInstrumentID()+"/chart/5y";

    request(url, function (error, response, body)
    {
        var myJSON = JSON.parse(body);

        assetsArray[k].setInstrumentPrice(parseFloat(myJSON[myJSON.length-1].close));

        for(var j = 0; j<myJSON.length; j++)
        {
          assetsArray[k].setHistoricalRentability(parseFloat(myJSON[j].changePercent) / 100);
        }
        portfolioObject.addInstrument(assetsArray[k]);
        k = k + 1;
    });
  }
  setTimeout(function()
  {
    var VaR = portfolioObject.computeVaR(parseFloat(probability));
    res.send('The VaR of the Portfolio is '+VaR+'$');
  }, 15000);
});

/**
 * Bank of England Official Statistics
 *
 * The 3 month Euribor Instrument ID is IUDERB3
 */
 app.get("/BOE/computeVaR/:probability/:nominal/:instrumentID/", function(req, res)
 {
   var portfolio = req.params.portfolio;
   var nominal = parseFloat(req.params.nominal);
   var instrumentID = req.params.instrumentID;

   var probability = req.params.probability;

   var intRate = new InterestRate(instrumentID, nominal);

   var startDate = getDate(5,0,0);

   var k = 0;

   var url = "https://www.quandl.com/api/v3/datasets/BOE/"+intRate.getInstrumentID()+".json?api_key=aFBPpVBg4L5fMsc9BWHs&start_date="+startDate;
   request(url, function (error, response, body)
   {
       var myJSON = JSON.parse(body);

       var data = myJSON.dataset.data;

       intRate.setActualInterestRate(parseFloat(data[0][1]));

       var lastValue = parseFloat(data[data.length-1][1]);
       var actualValue = 0;

       var _historicalInterestRateChange = 0;

       for(var j = data.length - 2; j > 0; j--)
       {
         actualValue = parseFloat(data[j][1]);
         _historicalInterestRateChange = (actualValue - lastValue) / lastValue;
         intRate.setHistoricalInterestRateChange(_historicalInterestRateChange);
         lastValue = actualValue;
       }
       k = 1;
   });
   setTimeout(function()
   {
     var VaR1 = Math.abs(intRate.computeVaR(parseFloat(probability)));
     var VaR2 = Math.abs(intRate.computeVaR(parseFloat(1 - probability)));
     res.json({"fixLeg" : VaR1, "variableLeg" : VaR2}); // Revisar
   }, 7000);
 });
