// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";

contract TestSlotDump is FraxTest {
    address instance;

    function testDumpSlots() public {
        instance = address(new Bravo());
        dumpStorageLayout(instance, 15);
    }
}

// ================== Helpers =============

contract Alpha {
    address owner = address(0xC0ffee);
    address pendingOwner;
}

contract Bravo is Alpha {
    bytes32 someValue = bytes32(type(uint).max);
    uint256[5] gap;
    bytes32 someOtherValue = 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
}
