pragma solidity ^0.4.20;

import "QuickSortOrder.sol";
import "Market.sol";

contract OrderBook is QuickSortOrder
{

  instrumentType instType;
  string instrumentID;
  string market;
  uint settlementTimestamp;

  address marketAddress;

  order[] askOrders;
  order[] bidOrders;
 // BID are buy orders
 // ASK are buy orders

     modifier onlyMarket()
     {
         require(marketAddress == msg.sender);
         _;
     }

     function OrderBook (string _instrumentID, string _market, instrumentType _instrumentType, uint _settlementTimestamp) public
     {
       instrumentID = _instrumentID;
       market = _market;
       instType = _instrumentType;
       marketAddress = msg.sender;
       settlementTimestamp = _settlementTimestamp;
     }
    // FIX ADD INS TYPE
    function addBuyOrder(address _ownerAddress, uint _quantity, uint _price) public /*onlyMarket*/
    {

        if (askOrders.length != 0)
        {
            uint i = 0;
            Market _market = Market(marketAddress);

            while(_price <= askOrders[i].price || _quantity > 0)
            {
                if(_quantity >= askOrders[i].quantity)
                {
                  if (instType == instrumentType.future)
                  {
                    _market.addFutureToCCP(_ownerAddress, askOrders[i].ownerAddress, instrumentID, uintToString(askOrders[i].quantity), uintPriceToString(askOrders[i].price), 10000, market);
                    _quantity = _quantity - askOrders[i].quantity;
                    removeOrder(askOrders, i);
                    i--;
                  }
                  else if (instType == instrumentType.swap)
                  {
                    //_market.addSwapToCCP(_ownerAddress, askOrders[i].ownerAddress, instrumentID, uintToString(askOrders[i].quantity), uintPriceToString(askOrders[i].price));
                  }
                }
                else
                {
                  if (instType == instrumentType.future)
                  {
                    _market.addFutureToCCP(_ownerAddress, askOrders[i].ownerAddress, instrumentID, uintToString(askOrders[i].quantity), uintPriceToString(askOrders[i].price), 10000, market);
                    askOrders[i].quantity = askOrders[i].quantity - _quantity;
                    _quantity = 0;
                  }
                  else if (instType == instrumentType.swap)
                  {
                    //_market.addSwapToCCP(_ownerAddress, askOrders[i].ownerAddress, instrumentID, uintToString(askOrders[i].quantity), uintPriceToString(askOrders[i].price));
                  }
                }
                i++;
            }
        }

        if(_quantity > 0)
        {
          addBidToOrderBook(_ownerAddress, _quantity, _price);
        }
    }

    event matches(string);
    function addSellOrder(address _ownerAddress, uint _quantity, uint _price) public /*onlyMarket*/
    {
        if (bidOrders.length != 0)
        {
            uint i = 0;
            Market _market = Market(marketAddress);

              while(_price >= bidOrders[i].price && _quantity > 0)
              {
                  if(_quantity >= bidOrders[i].quantity)
                  {
                    if (instType == instrumentType.future)
                    {
                      _market.addFutureToCCP(bidOrders[i].ownerAddress, _ownerAddress, instrumentID, uintToString(bidOrders[i].quantity), uintPriceToString(bidOrders[i].price), 10000, market);
                      _quantity = _quantity - bidOrders[i].quantity;
                      matches("We have a match 1");
                      removeOrder(bidOrders, i);
                      i--;
                    }
                    else if (instType == instrumentType.swap)
                    {
                      //_market.addSwapToCCP(_ownerAddress, askOrders[i].ownerAddress, instrumentID, uintToString(askOrders[i].quantity), uintPriceToString(askOrders[i].price));
                    }
                  }
                  else
                  {
                    if (instType == instrumentType.future)
                    {
                        matches("We have a match 2");
                      _market.addFutureToCCP(bidOrders[i].ownerAddress, _ownerAddress, instrumentID, uintToString(bidOrders[i].quantity), uintPriceToString(bidOrders[i].price), 10000, market);
                      bidOrders[i].quantity = bidOrders[i].quantity - _quantity;
                      _quantity = 0;
                    }
                    else if (instType == instrumentType.swap)
                    {
                      //_market.addSwapToCCP(_ownerAddress, askOrders[i].ownerAddress, instrumentID, uintToString(askOrders[i].quantity), uintPriceToString(askOrders[i].price));
                    }
                  }
                  i++;
              }
        }

      if(_quantity > 0)
      {
        addAskToOrderBook(_ownerAddress, _quantity, _price);
      }
    }

    function addBidToOrderBook(address _ownerAddress, uint _quantity, uint _price) internal
    {
      bidOrders.push(order(_ownerAddress, _quantity, block.timestamp,  _price));
      orderDecreasing(bidOrders);

      //Market _market = Market(marketAddress);
       //_market.bidOrderAddedToOrderBook();
    }

    function addAskToOrderBook(address _ownerAddress, uint _quantity, uint _price) internal
    {
      askOrders.push(order(_ownerAddress, _quantity, block.timestamp,  _price));
      orderDecreasing(bidOrders);

     // Market _market = Market(marketAddress);
       //_market.bidOrderAddedToOrderBook();
    }
}
