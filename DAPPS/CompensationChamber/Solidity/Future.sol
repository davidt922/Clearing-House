pragma solidity ^0.4.20;

import "Derivative.sol";
import "MarketData.sol";

contract Future is Derivative
{
    address longMemberContractAddress; // The one who will have to buy the asset (subyacente) in the settlementTimestamp
    address shortMemberContractAddress; // The one who will have to sell the asset (subyacente) in the settlementTimestamp
    string amount; // Amount of the subyacent asset that they have to trade at settlementTimestamp

    function Future(address _longMemberContractAddress, address _shortMemberContractAddress, string _instrumentID, string _amount, uint _settlementTimestamp, address _marketDataAddress, string _market) Derivative(_instrumentID, _settlementTimestamp, _marketDataAddress, _market) public payable
    {
        require(msg.value >= 1 ether);
        longMemberContractAddress = _longMemberContractAddress;
        shortMemberContractAddress = _shortMemberContractAddress;

        amount = _amount;

        computeIM();
    }

    function computeIM() private
    {
        MarketData marketDataContract = MarketData(marketDataAddress);

        if (compareStrings( market, "BOE")) // Bank of england
        {
          marketDataContract.getIMFutureBOE.value(1 ether)(amount, instrumentID);
        }
        else if (compareStrings(market, "EUREX")) // https://www.quandl.com/data/EUREX-EUREX-Futures-Data
        {
          marketDataContract.getIMFutureEUREX.value(1 ether)(amount, instrumentID);
        }
        else if (compareStrings(market, "CME"))// Chicago Mercantile Exchanges // https://www.quandl.com/data/CME-Chicago-Mercantile-Exchange-Futures-Data
        {
          marketDataContract.getIMFutureCME.value(1 ether)(amount, instrumentID);
        }
    }

    function setIM(string result) onlyMarketData public
    {
        uint[2] memory value = stringToUintArray2(result); // first value = longMemberContractAddress, second value = shortMemberContractAddress
        // FOR TEST Change value[0], value[1] for an integer
        paymentRequest(1000, longMemberContractAddress, paymentType.initialMargin);
        paymentRequest(1000, shortMemberContractAddress, paymentType.initialMargin);
    }

    function setVM(string result) onlyMarketData public
    {
        uint[2] memory value = stringToUintArray2(result); // first value = longMemberContractAddress, second value = shortMemberContractAddress

        paymentRequest(value[0], longMemberContractAddress, paymentType.variationMargin);
        paymentRequest(value[1], shortMemberContractAddress, paymentType.variationMargin);
    }

    function getTheContractCounterparts() public returns(address[2])
    {
        return [longMemberContractAddress, shortMemberContractAddress];
    }
}
