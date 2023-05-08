// SPDX-License-Identifier: ISC
pragma solidity ^0.8.19;

interface IOperatorRole {
    event OperatorTransferred(address indexed previousOperator, address indexed newOperator);

    function operatorAddress() external view returns (address);

    function setOperator() external;
}
