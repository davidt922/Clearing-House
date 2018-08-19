import { default as Web3} from 'web3';
import {BigNumber} from 'bignumber.js';

export default class PaymentRequest
{
  constructor()
  {
    this.paymentRequest = [];
  }
  addNewPaymentRequest(_transactionResult)
  {
    var args = _transactionResult.args;
    var paymentRequest = {paymentRequestAddress: args.paymentRequestAddress,clearingMemberAddress: args.clearingMemberAddress, value: new BigNumber(args.value).toNumber()};
    this.paymentRequest.push(paymentRequest);

    if (account == paymentRequest.paymentRequestAddress)
    {
      if (confirm("You have to pay "+ paymentRequest.value/1000000000000000000))
      {
        //txt = "You pressed OK!";
      }
      else
      {
        //txt = "You pressed Cancel!";
      }
    }
  }
}
