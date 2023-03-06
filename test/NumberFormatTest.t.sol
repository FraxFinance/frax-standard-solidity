// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";
import "../src/NumberFormat.sol";

contract NumberFormatTest is FraxTest {
    function testToScientific() public {
        uint256 _value = 123456789;
        string memory _expected = "1.23456789e8";
        string memory _actual = NumberFormat.toScientific(_value);
        assertEq(_expected, _actual);
    }

    function testToScientific2() public {
        uint256 _value = 1e18;
        string memory _expected = "1e18";
        string memory _actual = NumberFormat.toScientific(_value);
        assertEq(_expected, _actual);
    }

    function testToScientific3() public {
        uint256 _value = 1010;
        string memory _expected = "1.01e3";
        string memory _actual = NumberFormat.toScientific(_value);
        assertEq(_expected, _actual);
    }
}
