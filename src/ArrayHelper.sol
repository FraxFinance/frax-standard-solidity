library ArrayHelper {
    function concat(address[] memory _inputArray, address _newItem) internal pure returns (address[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new address[](_inputArrayLength + 1);
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
}
