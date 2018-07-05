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
        require(msg.value == 100);
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
          marketDataContract.getIMFutureBOE.value(100 wei)(amount, instrumentID);
        }
        else if (compareStrings(market, "EUREX")) // https://www.quandl.com/data/EUREX-EUREX-Futures-Data
        {
          marketDataContract.getIMFutureEUREX.value(100 wei)(amount, instrumentID);
        }
        else if (compareStrings(market, "CME"))// Chicago Mercantile Exchanges // https://www.quandl.com/data/CME-Chicago-Mercantile-Exchange-Futures-Data
        {
          marketDataContract.getIMFutureCME.value(100 wei)(amount, instrumentID);
        }
    }

    function setIM(string result) onlyMarketData public
    {
        uint[2] memory value = stringToUintArray2(result); // first value = longMemberContractAddress, second value = shortMemberContractAddress
        paymentRequest(value[0], longMemberContractAddress, paymentType.initialMargin);
        paymentRequest(value[1], shortMemberContractAddress, paymentType.initialMargin);
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
