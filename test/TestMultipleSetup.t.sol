// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";

contract TestMultipleSetup is FraxTest {
    uint256 public value;
    uint256 public runsPassed;

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
        vm.makePersistent(address(this));
    }

    function revertIfNotFive(uint256 _value) public pure {
        if (_value != 5) revert();
        else revert("Run Passed");
    }

    /// @notice Should fail if value is not 5, should fail differently if
    ///         value == 5
    function testAssertValue() public useMultipleSetupFunctions {
        if (value != 5) vm.expectRevert();
        else vm.expectRevert(bytes("Run Passed"));
        this.revertIfNotFive(value);
    }
}
