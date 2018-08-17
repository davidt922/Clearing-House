pragma experimental ABIEncoderV2;

import "./Derivative.sol";
import "./MarketData.sol";
import "./Utils.sol";
import "./PaymentRequest.sol";

contract Future is Derivative
{
  address longMemberAddress; // The one who will have to buy the asset (subyacente) in the settlementTimestamp
  address shortMemberAddress; // The one who will have to sell the asset (subyacente) in the settlementTimestamp
  bytes32 amount; // Amount of the subyacent asset that they have to trade at settlementTimestamp

  constructor (address _longMemberAddress, address _shortMemberAddress, bytes32 _instrumentID, bytes32 _amount, bytes32 _price, uint _settlementTimestamp, address _marketDataAddress, Utils.market _market) Derivative(_instrumentID, _settlementTimestamp, _marketDataAddress, _market, _price) public payable
  {
    require (msg.value >= 1 ether);

    longMemberAddress = _longMemberAddress;
    shortMemberAddress = _shortMemberAddress;
    amount = _amount;
    computeIM();
  }

  function computeIM() private
  {
    MarketData _marketDataContract = MarketData(marketDataAddress);

    if (market == Utils.market.BOE) // Bank of england
    {
      _marketDataContract.getIMFutureBOE.value(1 ether)(amount, instrumentID);
    }
    else if (market == Utils.market.EUREX) // https://www.quandl.com/data/EUREX-EUREX-Futures-Data
    {
      _marketDataContract.getIMFutureEUREX.value(1 ether)(amount, instrumentID);
    }
    else if (market == Utils.market.CME) // Chicago Mercantile Exchanges // https://www.quandl.com/data/CME-Chicago-Mercantile-Exchange-Futures-Data
    {
      _marketDataContract.getIMFutureCME.value(1 ether)(amount, instrumentID);
    }
  }

  function getTheContractCounterparts() public returns(address[2])
  {
      return [longMemberAddress, shortMemberAddress];
  }

  function setIM(string result) onlyMarketData public
  {
       //new PaymentRequest();
     // initialMargin[shortMemberAddress] = //new PaymentRequest(100, shortMemberAddress, compensationChamberAddress, Utils.paymentType.initialMargin);
  }


  function computeVM() public onlyChamber returns (Utils.variationMarginChange[2])
  {
      Utils.variationMarginChange[2] ret;
      ret[0] = Utils.variationMarginChange(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, 10);
      ret[1] = Utils.variationMarginChange(0xca35b7d915458ef540ade6068dfe2f44e8fa733c, 10);
      return ret;
  }

  function settlement() onlyChamber public
  {
    longMemberAddress.transfer(uint(initialMargin[longMemberAddress]*9/10));
    shortMemberAddress.transfer(uint(initialMargin[longMemberAddress]*9/10));

    selfdestruct(compensationChamberAddress);

  }
}
