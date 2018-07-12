pragma experimental ABIEncoderV2;
import "Derivative.sol";
import "MarketData.sol";
import "Utils.sol";
import "PaymentRequest.sol";

contract Future is Derivative
{
    address longMemberAddress; // The one who will have to buy the asset (subyacente) in the settlementTimestamp
    address shortMemberAddress; // The one who will have to sell the asset (subyacente) in the settlementTimestamp
    string amount; // Amount of the subyacent asset that they have to trade at settlementTimestamp

    function Future(address _longMemberAddress, address _shortMemberAddress, string _instrumentID, string _amount, string _price, uint _settlementTimestamp, address _marketDataAddress, string _market) Derivative(_instrumentID, _settlementTimestamp, _marketDataAddress, _market, _price) public payable
    {
        require (msg.value >= 1 ether);

        longMemberAddress = _longMemberAddress;
        shortMemberAddress = _shortMemberAddress;
        amount = _amount;
        computeIM();
    }

    function computeIM() private
    {
        MarketData marketDataContract = MarketData(marketDataAddress);

        if (Utils.compareStrings( market, "BOE")) // Bank of england
        {
          marketDataContract.getIMFutureBOE.value(1 ether)(amount, instrumentID);
        }
        else if (Utils.compareStrings(market, "EUREX")) // https://www.quandl.com/data/EUREX-EUREX-Futures-Data
        {
          marketDataContract.getIMFutureEUREX.value(1 ether)(amount, instrumentID);
        }
        else if (Utils.compareStrings(market, "CME"))// Chicago Mercantile Exchanges // https://www.quandl.com/data/CME-Chicago-Mercantile-Exchange-Futures-Data
        {
          marketDataContract.getIMFutureCME.value(1 ether)(amount, instrumentID);
        }
    }

    function setIM(string result) onlyMarketData public
    {
        initialMargin[longMemberAddress] = new PaymentRequest();
       // initialMargin[shortMemberAddress] = new PaymentRequest(100, shortMemberAddress, compensationChamberAddress, Utils.paymentType.initialMargin);
    }

    function computeVM() public onlyChamber returns (Utils.variationMarginChange[2])
    {
        Utils.variationMarginChange[2] ret;
        ret[0] = Utils.variationMarginChange(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, 10);
        ret[1] = Utils.variationMarginChange(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, 10);
        return ret;
    }

    function getTheContractCounterparts() public returns(address[2])
    {
        return [longMemberAddress, shortMemberAddress];
    }
}
