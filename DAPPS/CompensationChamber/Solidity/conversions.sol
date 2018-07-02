pragma solidity ^0.4.15;

import "./strings.sol";

contract conversions
{
  using strings for *;

  // Convert from bytes32 to String
  function bytes32ToString(bytes32 _bytes32) internal pure returns (string)
  {
    bytes memory bytesArray = new bytes(32);
    for (uint256 i; i < 32; i++)
    {
        bytesArray[i] = _bytes32[i];
    }
    var stringToParse = string(bytesArray).toSlice();
    strings.slice memory part;

    // remove all \u0000 after the word
    stringToParse.split("\u0000".toSlice(), part);
    return part.toString();
  }
  // Convert addressToString
  function addressToString(address x) internal pure returns (string)
  {
    bytes memory b = new bytes(20);

    for (uint i = 0; i < 20; i++)
    {
      b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));
    }
    return string(b);
  }
  // Convert string to bytes32
  function stringToBytes32(string memory source) internal pure returns (bytes32 result)
  {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0)
    {
        return 0x0;
    }
    assembly
    {
        result := mload(add(source, 32))
    }
  }
  // convert string of this type: [aa, bb, cc] to an array of bytes32 ["aa","bb","cc"]
  function stringToBytes32Array2(string result) internal pure returns (bytes32[2] memory)
  {
    // Posible improve here
    var stringToParse = result.toSlice();
    stringToParse.beyond("[".toSlice()).until("]".toSlice()); //remove [ and ]
    var delim = ",".toSlice();
    //var parts = new string[](stringToParse.count(delim) + 1);
    bytes32[2] memory parts;
    for (uint i = 0; i < parts.length; i++)
    {
        parts[i] = stringToBytes32(stringToParse.split(delim).toString());
    }
    // Finish possible improve
    return parts;
  }

  function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string)
  {
      bytes memory _ba = bytes(_a);
      bytes memory _bb = bytes(_b);
      bytes memory _bc = bytes(_c);
      bytes memory _bd = bytes(_d);
      bytes memory _be = bytes(_e);
      string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
      bytes memory babcde = bytes(abcde);
      uint k = 0;
      for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
      for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
      for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
      for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
      for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];
      return string(babcde);
  }

  function strConcat(string _a, string _b, string _c, string _d) internal pure returns (string)
  {
      return strConcat(_a, _b, _c, _d, "");
  }

  function strConcat(string _a, string _b, string _c) internal pure returns (string)
  {
      return strConcat(_a, _b, _c, "", "");
  }

  function strConcat(string _a, string _b) internal pure returns (string)
  {
      return strConcat(_a, _b, "", "", "");
  }

}
