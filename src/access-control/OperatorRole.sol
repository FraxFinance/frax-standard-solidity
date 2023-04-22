// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

// TODO ascii art

abstract contract OperatorRole {
    address public operatorAddress;

    constructor(address _operatorAddress) {
        operatorAddress = _operatorAddress;
    }

    // TODO fix headings
    // Externals

    function setOperator() external virtual {}

    // Internal actions
    function _setOperator(address _newOperator) internal {
        emit OperatorTransferred(operatorAddress, _newOperator);
        operatorAddress = _newOperator;
    }

    // Internal checks
    function _isOperator(address _address) internal view returns (bool _isOperator) {
        _isOperator = _address == operatorAddress;
    }

    function _requireIsOperator(address _address) internal view {
        if (!_isOperator(_address)) {
            revert AddressIsNotOperator(operatorAddress, _address);
        }
    }

    function _requireSenderIsOperator() internal view {
        _requireIsOperator(msg.sender);
    }

    // Events

    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    // Errors
    error AddressIsNotOperator(address operatorAddress, address actualAddress);
}
