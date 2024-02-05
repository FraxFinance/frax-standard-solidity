// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { console2 as console, StdAssertions, StdChains, StdCheats, stdError, StdInvariant, stdJson, stdMath, StdStorage, stdStorage, StdUtils, Vm, StdStyle, TestBase, DSTest, Test } from "forge-std/Test.sol";

import { VmHelper } from "./VmHelper.sol";

abstract contract FraxTest is VmHelper, Test {
    uint256[] internal snapShotIds;
    function()[] internal setupFunctions;

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

    error VmDidNotRevert(uint256 _snapshotId);
}
