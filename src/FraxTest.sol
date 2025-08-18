// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { console2 as console, StdAssertions, StdChains, StdCheats, stdError, StdInvariant, stdJson, stdMath, StdStorage, stdStorage, StdUtils, Vm, StdStyle, TestBase, Test } from "forge-std/Test.sol";
import { VmHelper } from "./VmHelper.sol";
import { Strings } from "./StringsHelper.sol";

abstract contract FraxTest is VmHelper, Test {
    /// @notice EIP-1967 Slots
    bytes32 internal IMPLEMENTATION_SLOT = bytes32(uint256(keccak256("eip1967.proxy.implementation")) - 1);
    bytes32 internal ADMIN_SLOT = bytes32(uint256(keccak256("eip1967.proxy.admin")) - 1);

    // ========================================================================
    // ~~~~~~~~~~~~~~~~~~~~~~~ EIP-1967 Proxy Helpers ~~~~~~~~~~~~~~~~~~~~~~~~~
    // ========================================================================

    /// @notice Helper function to efficiently return the address type located at the implementation
    ///         and admin slot on an EIP-1967 Proxy
    /// @param _proxyToCheck    The proxy to fetch the implementation and admin of
    /// @return implementation  The Implmentation of the `_proxyToCheck`
    /// @return admin           The Admin of the `_proxyToCheck`
    function get1967ProxyImplAndAdmin(
        address _proxyToCheck
    ) internal view returns (address implementation, address admin) {
        implementation = address(uint160(uint(vm.load(_proxyToCheck, IMPLEMENTATION_SLOT))));
        admin = address(uint160(uint(vm.load(_proxyToCheck, ADMIN_SLOT))));
    }

    /// @notice Variant of the above function but the returns will be logged to the console
    /// @param _proxyToCheck    The proxy to fetch the implementation and admin of
    /// @return implementation  The Implmentation of the `_proxyToCheck`
    /// @return admin           The Admin of the `_proxyToCheck`
    function get1967ProxyImplAndAdminWithLog(
        address _proxyToCheck
    ) internal view returns (address implementation, address admin) {
        (implementation, admin) = get1967ProxyImplAndAdmin(_proxyToCheck);
        console.log("           get1967ProxyImplAndAdminWithLog: Implementation - ", implementation);
        console.log("           get1967ProxyImplAndAdminWithLog: ProxyAdmin - ", admin);
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
