pragma experimental ABIEncoderV2;
contract QuickSortOrder
{
    event sortDone(string a);
  struct order
  {
    address ownerAddress;
    uint quantity;
    uint price; // the las 3 numbers of the integer represents the decimals, so 3000 equals to 3.
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

       // uint i = 0;
       // uint j = arr.length;

       /* while(i < j)
        {
               (arr[i].price, arr[j].price) = (arr[j].price, arr[i].price);
               (arr[i].quantity, arr[j].quantity) = (arr[j].quantity, arr[i].quantity);
               (arr[i].ownerAddress, arr[j].ownerAddress) = (arr[j].ownerAddress, arr[i].ownerAddress);
               i++;
               j--;
        }*/
    }

}
