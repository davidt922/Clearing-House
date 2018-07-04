pragma experimental ABIEncoderV2;

import "Utils.sol";

contract QuickSortOrder is OrderBookUtils
{
    event sortDone(string a);

  function orderIncreasing(order[] storage arr) internal
  {
      if(arr.length <= 1)
      {
          return;
      }
      else if(arr.length == 2)
      {
          if(arr[0].price > arr[1].price)
          {
            (arr[uint(0)].price, arr[uint(1)].price) = (arr[uint(1)].price, arr[uint(0)].price);
            (arr[uint(0)].quantity, arr[uint(1)].quantity) = (arr[uint(1)].quantity, arr[uint(0)].quantity);
            (arr[uint(0)].ownerAddress, arr[uint(1)].ownerAddress) = (arr[uint(1)].ownerAddress, arr[uint(0)].ownerAddress);
            (arr[uint(0)].timestamp, arr[uint(1)].timestamp) = (arr[uint(1)].timestamp, arr[uint(0)].timestamp);
          }
      }
      else
      {
        quickSortIncreasing(arr, 0, arr.length - 1);
      }

    for (uint i = 0; i < arr.length - 1; i++)
    {
        if (arr[i].price == arr[i+1].price)
        {
            if (arr[i].timestamp > arr[i+1].timestamp)
            {
                (arr[uint(i)].price, arr[uint(i+1)].price) = (arr[uint(i+1)].price, arr[uint(i)].price);
                (arr[uint(i)].quantity, arr[uint(i+1)].quantity) = (arr[uint(i+1)].quantity, arr[uint(i)].quantity);
                (arr[uint(i)].ownerAddress, arr[uint(i+1)].ownerAddress) = (arr[uint(i+1)].ownerAddress, arr[uint(i)].ownerAddress);
                (arr[uint(i)].timestamp, arr[uint(i+1)].timestamp) = (arr[uint(i+1)].timestamp, arr[uint(i)].timestamp);
            }
        }
    }
  }

  function orderDecreasing(order[] storage arr) internal
  {
      if(arr.length <= 1)
      {
          return;
      }
      else if(arr.length == 2)
      {
          if(arr[0].price < arr[1].price)
          {
            (arr[uint(0)].price, arr[uint(1)].price) = (arr[uint(1)].price, arr[uint(0)].price);
            (arr[uint(0)].quantity, arr[uint(1)].quantity) = (arr[uint(1)].quantity, arr[uint(0)].quantity);
            (arr[uint(0)].ownerAddress, arr[uint(1)].ownerAddress) = (arr[uint(1)].ownerAddress, arr[uint(0)].ownerAddress);
            (arr[uint(0)].timestamp, arr[uint(1)].timestamp) = (arr[uint(1)].timestamp, arr[uint(0)].timestamp);
          }
      }
      else
      {
        quickSortDecreasing(arr, 0, arr.length - 1);
      }

    for (uint i = 0; i < arr.length - 1; i++)
    {
        if (arr[i].price == arr[i+1].price)
        {
            if (arr[i].timestamp < arr[i+1].timestamp)
            {
                (arr[uint(i)].price, arr[uint(i+1)].price) = (arr[uint(i+1)].price, arr[uint(i)].price);
                (arr[uint(i)].quantity, arr[uint(i+1)].quantity) = (arr[uint(i+1)].quantity, arr[uint(i)].quantity);
                (arr[uint(i)].ownerAddress, arr[uint(i+1)].ownerAddress) = (arr[uint(i+1)].ownerAddress, arr[uint(i)].ownerAddress);
                (arr[uint(i)].timestamp, arr[uint(i+1)].timestamp) = (arr[uint(i+1)].timestamp, arr[uint(i)].timestamp);
            }
        }
    }
  }

  function quickSortIncreasing(order[] storage arr, uint left, uint right) internal
  {
         uint i = left;
         uint j = right;

        if(i==j)
        {
            return;
        }

         uint pivot = arr[uint(left + (right - left) / 2)].price;

         while (i <= j)
         {
            while (arr[uint(i)].price < pivot)
            {
                i++;
            }

            while (pivot < arr[uint(j)].price)
            {
               j--;
            }

           if (i <= j)
           {
               (arr[uint(i)].price, arr[uint(j)].price) = (arr[uint(j)].price, arr[uint(i)].price);
               (arr[uint(i)].quantity, arr[uint(j)].quantity) = (arr[uint(j)].quantity, arr[uint(i)].quantity);
               (arr[uint(i)].ownerAddress, arr[uint(j)].ownerAddress) = (arr[uint(j)].ownerAddress, arr[uint(i)].ownerAddress);
               (arr[uint(i)].timestamp, arr[uint(j)].timestamp) = (arr[uint(j)].timestamp, arr[uint(i)].timestamp);
               i++;
               j--;
           }
         }

         if (left < j)
         {
            quickSortIncreasing(arr, left, j);
         }

         if (i < right)
         {
            quickSortIncreasing(arr, i, right);
         }
    }

    function quickSortDecreasing(order[] storage arr, uint left, uint right) internal
    {
        quickSortIncreasing(arr, left,right);

        uint i = 0;
        uint j = arr.length - 1;

        while(i <= j)
        {
               (arr[uint(i)].price, arr[uint(j)].price) = (arr[uint(j)].price, arr[uint(i)].price);
               (arr[uint(i)].quantity, arr[uint(j)].quantity) = (arr[uint(j)].quantity, arr[uint(i)].quantity);
               (arr[uint(i)].ownerAddress, arr[uint(j)].ownerAddress) = (arr[uint(j)].ownerAddress, arr[uint(i)].ownerAddress);
               (arr[uint(i)].timestamp, arr[uint(j)].timestamp) = (arr[uint(j)].timestamp, arr[uint(i)].timestamp);
               i++;
               j--;
        }
    }

}
