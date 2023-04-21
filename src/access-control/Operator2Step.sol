// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== Operator2Step ===========================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// Reviewers
// Dennis: https://github.com/denett

// ====================================================================

/// @title Operator2Step
/// @author Drake Evans (Frax Finance) https://github.com/drakeevans
/// @dev Inspired by OpenZeppelin's Ownable2Step contract
/// @notice  An abstract contract which contains 2-step transfer and renounce logic for a operator address
abstract contract Operator2Step {
    /// @notice The pending operator address
    address public pendingOperatorAddress;

    /// @notice The current operator address
    address public operatorAddress;

    constructor() {
        operatorAddress = msg.sender;
    }

    // ============================================================================================
    // Functions: External Functions
    // ============================================================================================

    /// @notice The ```transferOperator``` function initiates the operator transfer
    /// @dev Must be called by the current operator
    /// @param _newOperator The address of the nominated (pending) operator
    function transferOperator(address _newOperator) external virtual {
        _requireSenderIsOperator();
        _transferOperator(_newOperator);
    }

    /// @notice The ```acceptTransferOperator``` function completes the operator transfer
    /// @dev Must be called by the pending operator
    function acceptTransferOperator() external virtual {
        _requireSenderIsPendingOperator();
        _acceptTransferOperator();
    }

    /// @notice The ```renounceOperator``` function renounces the operator after setting pending operator to current operator
    /// @dev Pending operator must be set to current operator before renouncing, creating a 2-step renounce process
    function renounceOperator() external virtual {
        _requireSenderIsOperator();
        _requireSenderIsPendingOperator();
        _transferOperator(address(0));
        _setOperator(address(0));
    }

    // ============================================================================================
    // Functions: Internal Actions
    // ============================================================================================

    /// @notice The ```_transferOperator``` function initiates the operator transfer
    /// @dev This function is to be implemented by a public function
    /// @param _newOperator The address of the nominated (pending) operator
    function _transferOperator(address _newOperator) internal {
        pendingOperatorAddress = _newOperator;
        emit OperatorTransferStarted(operatorAddress, _newOperator);
    }

    /// @notice The ```_acceptTransferOperator``` function completes the operator transfer
    /// @dev This function is to be implemented by a public function
    function _acceptTransferOperator() internal {
        pendingOperatorAddress = address(0);
        _setOperator(msg.sender);
    }

    /// @notice The ```_setOperator``` function sets the operator address
    /// @dev This function is to be implemented by a public function
    /// @param _newOperator The address of the new operator
    function _setOperator(address _newOperator) internal {
        emit OperatorTransferred(operatorAddress, _newOperator);
        operatorAddress = _newOperator;
    }

    // ============================================================================================
    // Functions: Internal Checks
    // ============================================================================================

    /// @notice The ```_isOperator``` function checks if _address is current operator address
    /// @param _address The address to check against the operator
    /// @return Whether or not msg.sender is current operator address
    function _isOperator(address _address) internal view returns (bool) {
        return _address == operatorAddress;
    }

    /// @notice The ```_requireIsOperator``` function reverts if _address is not current operator address
    /// @param _address The address to check against the operator
    function _requireIsOperator(address _address) internal view {
        if (!_isOperator(_address)) revert SenderIsNotOperator();
    }

    /// @notice The ```_requireSenderIsOperator``` function reverts if msg.sender is not current operator address
    /// @dev This function is to be implemented by a public function
    function _requireSenderIsOperator() internal view {
        _requireIsOperator(msg.sender);
    }

    /// @notice The ```_isPendingOperator``` function checks if the _address is pending operator address
    /// @dev This function is to be implemented by a public function
    /// @param _address The address to check against the pending operator
    /// @return Whether or not _address is pending operator address
    function _isPendingOperator(address _address) internal view returns (bool) {
        return _address == pendingOperatorAddress;
    }

    /// @notice The ```_requireIsPendingOperator``` function reverts if the _address is not pending operator address
    /// @dev This function is to be implemented by a public function
    /// @param _address The address to check against the pending operator
    function _requireIsPendingOperator(address _address) internal view {
        if (!_isPendingOperator(_address)) revert SenderIsNotPendingOperator();
    }

    /// @notice The ```_requirePendingOperator``` function reverts if msg.sender is not pending operator address
    /// @dev This function is to be implemented by a public function
    function _requireSenderIsPendingOperator() internal view {
        _requireIsPendingOperator(msg.sender);
    }

    // ============================================================================================
    // Functions: Events
    // ============================================================================================

    /// @notice The ```OperatorTransferStarted``` event is emitted when the operator transfer is initiated
    /// @param previousOperator The address of the previous operator
    /// @param newOperator The address of the new operator
    event OperatorTransferStarted(address indexed previousOperator, address indexed newOperator);

    /// @notice The ```OperatorTransferred``` event is emitted when the operator transfer is completed
    /// @param previousOperator The address of the previous operator
    /// @param newOperator The address of the new operator
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    // ============================================================================================
    // Functions: Errors
    // ============================================================================================

    /// @notice Emitted when operator is transferred
    error SenderIsNotOperator();

    /// @notice Emitted when pending operator is transferred
    error SenderIsNotPendingOperator();
}
