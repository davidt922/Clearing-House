pragma experimental ABIEncoderV2;
contract OrderBook is QuickSortOrder
{
  bytes32 instrumentID;
  bytes32 market;

  order[] askOrders;
  order[] bidOrders;

    function addBid(address _ownerAddress, uint _quantity, uint _price)
    {
        bidOrders.push(order(_ownerAddress, _quantity, _price));
        sortDecreasing(bidOrders);
    }

    function addAsk(address _ownerAddress, uint _quantity, uint _price)
    {
        askOrders.push(order(_ownerAddress, _quantity, _price));
        sortIncreasing(askOrders);
    }

  function sortIncreasing(order[] storage array) private
  {
      if(array.length > 1)
      {
        quickSortIncreasing(array, 0, array.length - 1);
      }
  }

  function sortDecreasing(order[] storage array) private
  {
      if(array.length > 1)
      {
        quickSortDecreasing(array, 0, array.length - 1);
      }
  }

  function getArray(uint i) view returns(uint)
  {
      return askOrders[i].price;
  }
}
