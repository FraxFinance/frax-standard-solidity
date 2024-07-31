// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";

contract TestSlotDump is FraxTest {
    address instance;

    function testDumpSlots() public {
        instance = address(new Charlie());
        dumpStorageLayout(instance, 15);
    }

    function testUnpackSlotBytes() public {
        instance = address(new Charlie());
        dumpStorageLayout(instance, 15);

        bytes32 packedSlot = vm.load(address(instance), bytes32(uint(9)));
        uint256 unpacked1 = unpackBitsAndLogUint(packedSlot, 0, 96);
        uint256 unpacked2 = unpackBitsAndLogUint(packedSlot, 96, 160);

        /// @notice `unpacked1` is `uint96` expressed as `uint256`
        assertEq(22222222222222222222, unpacked1);
        assertEq(22222222222222222222, uint96(unpacked1));

        /// @notice `unpacked2` is `address` expressed as `uint256`
        assertEq(uint256(uint160(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)), unpacked2);
        assertEq(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, address(uint160(unpacked2)));
    }

    function testUnpackSlotUint() public {
        instance = address(new Charlie());
        dumpStorageLayout(instance, 15);

        uint256 packedSlot = uint256(vm.load(address(instance), bytes32(uint(9))));
        uint256 unpacked1 = unpackBitsAndLogUint(packedSlot, 0, 96);
        uint256 unpacked2 = unpackBitsAndLogUint(packedSlot, 96, 160);

        /// @notice `unpacked1` is `uint96` expressed as `uint256`
        assertEq(22222222222222222222, unpacked1);
        assertEq(22222222222222222222, uint96(unpacked1));

        /// @notice `unpacked2` is `address` expressed as `uint256`
        assertEq(uint256(uint160(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)), unpacked2);
        assertEq(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE, address(uint160(unpacked2)));
    }
}

// ================== Helpers ==================

contract Alpha {
    address owner = address(0xC0ffee);
    address pendingOwner;
}

contract Bravo is Alpha {
    bytes32 someValue = bytes32(type(uint).max);
    uint256[5] gap;
    bytes32 someOtherValue = 0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA;
}

contract Charlie is Bravo {
    uint96 packed1 = 22222222222222222222;
    address packed2 = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;
}
