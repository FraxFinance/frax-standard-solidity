// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Ownable2StepUpgradeable } from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";

/**
 * @title Proxy
 * @notice Proxy is a transparent proxy that passes through the call if the caller is the owner or
 *         if the caller is address(0), meaning that the call originated from an off-chain
 *         simulation.
 * @dev From ethereum-optimism/packages/contracts-bedrock/src/universal/Proxy.sol with loose version
 */
contract Proxy is Ownable2StepUpgradeable {
    /**
     * @notice The storage slot that holds the address of the implementation.
     *         bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1)
     */
    bytes32 internal constant IMPLEMENTATION_KEY = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

    /**
     * @notice The storage slot that holds the address of the owner.
     *         bytes32(uint256(keccak256('eip1967.proxy.admin')) - 1)
     */
    bytes32 internal constant OWNER_KEY = 0xb53127684a568b3173ae13b9f8a6016e243e63b6e8ee1178d6a717850b5d6103;

    /**
     * @notice An event that is emitted each time the implementation is changed. This event is part
     *         of the EIP-1967 specification.
     *
     * @param implementation The address of the implementation contract
     */
    event Upgraded(address indexed implementation);

    /**
     * @notice A modifier that reverts if not called by the owner or by address(0) to allow
     *         eth_call to interact with this proxy without needing to use low-level storage
     *         inspection. We assume that nobody is able to trigger calls from address(0) during
     *         normal EVM execution.
     */
    modifier proxyCallIfNotOwner() {
        if (msg.sender == owner() || msg.sender == address(0)) {
            _;
        } else {
            // This WILL halt the call frame on completion.
            _doProxyCall();
        }
    }

    constructor(address _owner) {
        _transferOwnership(_owner);
    }

    // slither-disable-next-line locked-ether
    receive() external payable {
        // Proxy call by default.
        _doProxyCall();
    }

    // slither-disable-next-line locked-ether
    fallback() external payable {
        // Proxy call by default.
        _doProxyCall();
    }

    /**
     * @notice Set the implementation contract address. The code at the given address will execute
     *         when this contract is called.
     *
     * @param _implementation Address of the implementation contract.
     */
    function upgradeTo(address _implementation) public virtual proxyCallIfNotOwner {
        _setImplementation(_implementation);
    }

    /**
     * @notice Set the implementation and call a function in a single transaction. Useful to ensure
     *         atomic execution of initialization-based upgrades.
     *
     * @param _implementation Address of the implementation contract.
     * @param _data           Calldata to delegatecall the new implementation with.
     */
    function upgradeToAndCall(
        address _implementation,
        bytes calldata _data
    ) public payable virtual proxyCallIfNotOwner returns (bytes memory) {
        _setImplementation(_implementation);
        (bool success, bytes memory returndata) = _implementation.delegatecall(_data);
        require(success, "Proxy: delegatecall to new implementation contract failed");
        return returndata;
    }

    /**
     * @notice Queries the implementation address.
     *
     * @return Implementation address.
     */
    function implementation() public virtual proxyCallIfNotOwner returns (address) {
        return _getImplementation();
    }

    /**
     * @notice Sets the implementation address.
     *
     * @param _implementation New implementation address.
     */
    function _setImplementation(address _implementation) internal {
        assembly {
            sstore(IMPLEMENTATION_KEY, _implementation)
        }
        emit Upgraded(_implementation);
    }

    /**
     * @notice Performs the proxy call via a delegatecall.
     */
    function _doProxyCall() internal {
        address impl = _getImplementation();
        require(impl != address(0), "Proxy: implementation not initialized");

        assembly {
            // Copy calldata into memory at 0x0....calldatasize.
            calldatacopy(0x0, 0x0, calldatasize())

            // Perform the delegatecall, make sure to pass all available gas.
            let success := delegatecall(gas(), impl, 0x0, calldatasize(), 0x0, 0x0)

            // Copy returndata into memory at 0x0....returndatasize. Note that this *will*
            // overwrite the calldata that we just copied into memory but that doesn't really
            // matter because we'll be returning in a second anyway.
            returndatacopy(0x0, 0x0, returndatasize())

            // Success == 0 means a revert. We'll revert too and pass the data up.
            if iszero(success) {
                revert(0x0, returndatasize())
            }

            // Otherwise we'll just return and pass the data up.
            return(0x0, returndatasize())
        }
    }

    /**
     * @notice Queries the implementation address.
     *
     * @return Implementation address.
     */
    function _getImplementation() internal view returns (address) {
        address impl;
        assembly {
            impl := sload(IMPLEMENTATION_KEY)
        }
        return impl;
    }
}
