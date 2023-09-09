// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

library ArrayHelper {
    function concat(address[] memory _inputArray, address _newItem) internal pure returns (address[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new address[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }
    
    function concat(function()[] memory _inputArray, function() _newItem) internal pure returns (function()[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new function()[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }

    function concat(bool[] memory _inputArray, bool _newItem) internal pure returns (bool[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new bool[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }

    function concat(uint128[] memory _inputArray, uint128 _newItem) internal pure returns (uint128[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new uint128[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }

    function concat(uint32[] memory _inputArray, uint32 _newItem) internal pure returns (uint32[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new uint32[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }

    function concat(bytes32[] memory _inputArray, bytes32 _newItem) internal pure returns (bytes32[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new bytes32[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }

    function concat(
        bytes[] memory _inputArray,
        bytes memory _newItem
    ) internal pure returns (bytes[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new bytes[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }

    function concat(uint256[] memory _inputArray, uint256 _newItem) internal pure returns (uint256[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new uint256[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }
}
