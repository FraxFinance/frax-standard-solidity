// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { console2 as console, StdAssertions, StdChains, StdCheats, stdError, StdInvariant, stdJson, stdMath, StdStorage, stdStorage, StdUtils, Vm, StdStyle, TestBase, DSTest, Test } from "forge-std/Test.sol";
import { VmHelper } from "./VmHelper.sol";
import { Strings } from "./StringsHelper.sol";

abstract contract FraxTest is VmHelper, Test {
    uint256[] internal snapShotIds;
    function()[] internal setupFunctions;

    // ========================================================================
    // ~~~~~~~~~~~~~~~~~~ Different State Testing Helpers ~~~~~~~~~~~~~~~~~~~~~
    // ========================================================================

    modifier useMultipleSetupFunctions() {
        if (snapShotIds.length == 0) _;
        for (uint256 i = 0; i < snapShotIds.length; i++) {
            uint256 _originalSnapshotId = vm.snapshot();
            if (!vm.revertTo(snapShotIds[i])) {
                revert VmDidNotRevert(snapShotIds[i]);
            }
            _;
            vm.clearMockedCalls();
            vm.revertTo(_originalSnapshotId);
        }
    }

    function addSetupFunctions(function()[] memory _setupFunctions) internal {
        for (uint256 i = 0; i < _setupFunctions.length; i++) {
            _setupFunctions[i]();
            snapShotIds.push(vm.snapshot());
            vm.clearMockedCalls();
        }
    }

    // ========================================================================
    // ~~~~~~~~~~~~~~~~~~~~~~~ Storage Slot Helpers ~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ========================================================================

    /// @notice Helper function to dump the storage slots of a contract to the console
    /// @param target      The target contract whose state we wish to view
    /// @param slotsToDump The # of lower storage slots we want to log
    function dumpStorageLayout(address target, uint256 slotsToDump) internal view {
        console.log("===================================");
        console.log("Storage dump for: ", target);
        console.log("===================================");
        for (uint i; i <= slotsToDump; i++) {
            bytes32 slot = vm.load(target, bytes32(uint256(i)));
            string memory exp = Strings.toHexString(uint256(slot), 32);
            console.log("slot", i, ":", exp);
        }
    }

    /// @notice Helper function for unpacking low level storage slots
    /// @param dataToUnpack The bytes32|uint256 of the slot to unpack
    /// @param offset       The bits to remove st. the target bits are LSB
    /// @param lenOfTarget  The length target result in bits
    /// @return result      The target bits expressed as a uint256
    function unpackBits(
        uint256 dataToUnpack,
        uint256 offset,
        uint256 lenOfTarget
    ) internal pure returns (uint256 result) {
        uint256 mask = (1 << lenOfTarget) - 1;
        result = (dataToUnpack >> offset) & mask;
    }

    function unpackBits(
        bytes32 dataToUnpack,
        uint256 offset,
        uint256 lenOfTarget
    ) internal pure returns (uint256 result) {
        uint256 mask = (1 << lenOfTarget) - 1;
        result = (uint256(dataToUnpack) >> offset) & mask;
    }

    function unpackBitsAndLogUint(
        uint256 dataToUnpack,
        uint256 offset,
        uint256 lenOfTarget
    ) internal pure returns (uint256 result) {
        result = unpackBits(dataToUnpack, offset, lenOfTarget);
        console.log(result);
    }

    function unpackBitsAndLogUint(
        bytes32 dataToUnpack,
        uint256 offset,
        uint256 lenOfTarget
    ) internal pure returns (uint256 result) {
        result = unpackBits(dataToUnpack, offset, lenOfTarget);
        console.log(result);
    }

    error VmDidNotRevert(uint256 _snapshotId);
}
