// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import {
    console2 as console,
    StdAssertions,
    StdChains,
    StdCheats,
    stdError,
    StdInvariant,
    stdJson,
    stdMath,
    StdStorage,
    stdStorage,
    StdUtils,
    Vm,
    StdStyle,
    TestBase,
    DSTest,
    Test
} from "forge-std/Test.sol";

import { VmHelper } from "./VmHelper.sol";

abstract contract FraxTest is VmHelper, Test {
    uint256[] internal snapShotIds;

    modifier useMultipleSetupFunctions() {
        for (uint256 i = 0; i < snapShotIds.length; i++) {
            if (!vm.revertTo(snapShotIds[i])) {
                revert VmDidNotRevert(snapShotIds[i]);
            }
            _;
            vm.clearMockedCalls();
        }
    }

    error VmDidNotRevert(uint256 _snapshotId);
}
