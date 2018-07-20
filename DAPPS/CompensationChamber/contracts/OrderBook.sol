// It doesen't work well

pragma experimental ABIEncoderV2;

import "./QuickSortOrder.sol";
import "./Market.sol";
import "./Utils.sol";

contract OrderBook is QuickSortOrder
{
    Utils.instrumentType instType;
    string instrumentID;
    string market;
    uint settlementTimestamp;

    address marketAddress;

    // ASK are sell orders
    Utils.order[] askOrders;
    // BID are buy orders
    Utils.order[] bidOrders;

    modifier onlyMarket()
    {
        require (marketAddress == msg.sender);
        _;
    }

    function OrderBook(string _instrumentID, string _market, Utils.instrumentType _instrumentType, uint _settlementTimestamp) public
    {
        instrumentID = _instrumentID;
        market = _market;
        instType = _instrumentType;
        marketAddress = msg.sender;
        settlementTimestamp = _settlementTimestamp;
    }
    // In this case we consider than _clearingMemberAddress is equals to _MarketMemberAddress
    function addBuyOrder(address _clearingMemberAddress, uint _quantity, uint _price) public onlyMarket
    {
        if (askOrders.length != 0)
        {
            uint i = 0;
            Market _marketContract = Market(marketAddress);

            while (_price <= askOrders[i].price || _quantity > 0)
            {
                if (_quantity >= askOrders[i].quantity)
                {
                    if (instType == Utils.instrumentType.future)
                    {
                        _marketContract.addFutureToCCP(_clearingMemberAddress, askOrders[i].clearingMemberAddress, instrumentID, Utils.uintToString(askOrders[i].quantity), Utils.uintPriceToString(askOrders[i].price), settlementTimestamp, market);
                    }
                    else if (instType == Utils.instrumentType.swap)
                    {
                        //_marketContract.addSwapToCCP(_clearingMemberAddress, askOrders[i].clearingMemberAddress, instrumentID, Utils.uintToString(askOrders[i].quantity), Utils.uintPriceToString(askOrders[i].price), settlementTimestamp, market);
                    }
                }
                else
                {
                    if (instType == Utils.instrumentType.future)
                    {
                        _marketContract.addFutureToCCP(_clearingMemberAddress, askOrders[i].clearingMemberAddress, instrumentID, Utils.uintToString(_quantity), Utils.uintPriceToString(askOrders[i].price), settlementTimestamp, market);
                    }
                    else if (instType == Utils.instrumentType.swap)
                    {
                        //_marketContract.addSwapToCCP(_clearingMemberAddress, askOrders[i].clearingMemberAddress, instrumentID, Utils.uintToString(_quantity), Utils.uintPriceToString(askOrders[i].price), settlementTimestamp, market);
                    }
                }
                (i, _quantity) = removeAskFromOrderBook(i, _quantity);
                i++;
            }
        }

        if (_quantity > 0)
        {
          addBidToOrderBook(_clearingMemberAddress, _quantity, _price);
        }
    }

    function addSellOrder(address _clearingMemberAddress, uint _quantity, uint _price) public onlyMarket
    {
        if (bidOrders.length != 0)
        {
            uint i = 0;
            Market _marketContract = Market(marketAddress);

            while (_price >= bidOrders[i].price && _quantity > 0)
            {
                if (_quantity >= bidOrders[i].quantity)
                {
                    if (instType == Utils.instrumentType.future)
                    {
                        _marketContract.addFutureToCCP(bidOrders[i].clearingMemberAddress, _clearingMemberAddress, instrumentID, Utils.uintToString(bidOrders[i].quantity), Utils.uintPriceToString(bidOrders[i].price), settlementTimestamp, market);
                    }
                    else if (instType == Utils.instrumentType.swap)
                    {
                        //_marketContract.addSwapToCCP(bidOrders[i].clearingMemberAddress, _clearingMemberAddress, instrumentID, Utils.uintToString(bidOrders[i].quantity), Utils.uintPriceToString(bidOrders[i].price), settlementTimestamp, market);
                    }
                }
                else
                {
                    if (instType == Utils.instrumentType.future)
                    {
                        _marketContract.addFutureToCCP(bidOrders[i].clearingMemberAddress, _clearingMemberAddress, instrumentID, Utils.uintToString(_quantity), Utils.uintPriceToString(bidOrders[i].price), settlementTimestamp, market);
                    }
                    else if (instType == Utils.instrumentType.swap)
                    {
                        //_marketContract.addSwapToCCP(bidOrders[i].clearingMemberAddress, _clearingMemberAddress, instrumentID, Utils.uintToString(_quantity), Utils.uintPriceToString(bidOrders[i].price), settlementTimestamp, market);
                    }
                }
                (i, _quantity) = removeBidFromOrderBook(i, _quantity);
                i++;
            }
        }

        if (_quantity > 0)
        {
            addAskToOrderBook(_clearingMemberAddress, _quantity, _price);
        }
    }

    function addBidToOrderBook(address _clearingMemberAddress, uint _quantity, uint _price) internal
    {
        bidOrders.push(Utils.order(_clearingMemberAddress, _quantity, block.timestamp,  _price));
        orderDecreasing(bidOrders);
        Market _marketContract = Market(marketAddress);
        _marketContract.addOrderEvent(instrumentID, _quantity, _price, 1);
    }

    function addAskToOrderBook(address _clearingMemberAddress, uint _quantity, uint _price) internal
    {
        askOrders.push(Utils.order(_clearingMemberAddress, _quantity, block.timestamp,  _price));
        orderDecreasing(askOrders);
        Market _marketContract = Market(marketAddress);
        _marketContract.addOrderEvent(instrumentID, _quantity, _price, 0);
    }

    function removeAskFromOrderBook(uint i, uint quantity) returns (uint _i, uint _quantity)
    {
      Market _marketContract = Market(marketAddress);

      if (_quantity >= askOrders[i].quantity)
      {
        quantity = quantity - askOrders[i].quantity;
        _marketContract.removeOrderEvent(instrumentID, askOrders[i].quantity, askOrders[i].price, 0);
        Utils.removeOrder(askOrders, i);
        i--;
      }
      else if (_quantity < askOrders[i].quantity)
      {
        askOrders[i].quantity = askOrders[i].quantity - quantity;
        _marketContract.removeOrderEvent(instrumentID, quantity, askOrders[i].price, 0);
        quantity = 0;
      }
      _i = i;
      _quantity = quantity;
    }

    function removeBidFromOrderBook(uint i, uint quantity) returns (uint _i, uint _quantity)
    {
      Market _marketContract = Market(marketAddress);

      if (quantity >= bidOrders[i].quantity)
      {
        quantity = quantity - bidOrders[i].quantity;
        _marketContract.removeOrderEvent(instrumentID, bidOrders[i].quantity, bidOrders[i].price, 1);
        Utils.removeOrder(bidOrders, i);
        i--;
      }
      else if (_quantity < bidOrders[i].quantity)
      {
        bidOrders[i].quantity = bidOrders[i].quantity - quantity;
        _marketContract.removeOrderEvent(instrumentID, _quantity, bidOrders[i].price, 1);
        quantity = 0;
      }
      _i = i;
      _quantity = quantity;
    }
    function getInstrumentID() returns (string)
    {
      return instrumentID;
    }

    function getAskOrdersLength() returns (uint)
    {
      return askOrders.length;
    }

    function getBidOrdersLength() returns (uint)
    {
      return bidOrders.length;
    }

    function getAskOrders(uint i) public constant returns (Utils.marketOrder _marketOrder)
    {
        _marketOrder = Utils.marketOrder(askOrders[i].quantity, askOrders[i].price);
    }

    function getBidOrders(uint i) public constant returns (Utils.marketOrder _marketOrder)
    {
      _marketOrder = Utils.marketOrder(bidOrders[i].quantity, bidOrders[i].price);
    }
}
