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
    function addBuyOrder(address _clearingMemberAddress, uint _quantity, uint _price) public onlyMarket returns(uint quantity, uint price)
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

                    _quantity = _quantity - askOrders[i].quantity;
                    Utils.removeOrder(askOrders, i);
                    i--;
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

                    askOrders[i].quantity = askOrders[i].quantity - _quantity;
                    _quantity = 0;

                    if (askOrders[i].quantity == 0)
                    {
                      Utils.removeOrder(askOrders, i);
                      i--;
                    }
                }
                i++;
            }
        }

        if (_quantity > 0)
        {
          addBidToOrderBook(_clearingMemberAddress, _quantity, _price);
          quantity = _quantity;
          price = _price;
        }
    }

    function addSellOrder(address _clearingMemberAddress, uint _quantity, uint _price) public onlyMarket returns(uint quantity, uint price)
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

                    _quantity = _quantity - bidOrders[i].quantity;
                    Utils.removeOrder(bidOrders, i);
                    i--;
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
                    bidOrders[i].quantity = bidOrders[i].quantity - _quantity;
                    _quantity = 0;

                    if (bidOrders[i].quantity == 0)
                    {
                      Utils.removeOrder(bidOrders, i);
                      i--;
                    }
                }
                i++;
            }
        }

        if (_quantity > 0)
        {
            addAskToOrderBook(_clearingMemberAddress, _quantity, _price);
            quantity = _quantity;
            price = _price;
        }
    }

    function addBidToOrderBook(address _clearingMemberAddress, uint _quantity, uint _price) internal
    {
        bidOrders.push(Utils.order(_clearingMemberAddress, _quantity, block.timestamp,  _price));
        orderDecreasing(bidOrders);
    }

    function addAskToOrderBook(address _clearingMemberAddress, uint _quantity, uint _price) internal
    {
        askOrders.push(Utils.order(_clearingMemberAddress, _quantity, block.timestamp,  _price));
        orderDecreasing(askOrders);
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
