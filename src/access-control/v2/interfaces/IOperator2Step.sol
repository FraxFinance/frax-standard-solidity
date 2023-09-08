// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.0;

interface IOperator2Step {
    event OperatorTransferStarted(address indexed previousOperator, address indexed newOperator);
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    function acceptTransferOperator() external;

    function operatorAddress() external view returns (address);

    function pendingOperatorAddress() external view returns (address);

    function renounceOperator() external;

    function transferOperator(address _newOperator) external;
}
