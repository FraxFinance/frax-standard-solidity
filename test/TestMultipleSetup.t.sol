// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";

contract TestMultipleSetup is FraxTest {
    uint256 value;

    function initializeValueOne() public {
        value = 25;
    }

    function initializeValueTwo() public {
        value = 5;
    }

    function initializeValueThree() public {
        value = 10;
    }

    function setUp() public {
        setupFunctions.push(initializeValueOne);
        setupFunctions.push(initializeValueTwo);
        setupFunctions.push(initializeValueThree);
        addSetupFunctions(setupFunctions);
    }

    function testFailAssertValue() public useMultipleSetupFunctions {
        assertEq(value, 5);
    }
}
