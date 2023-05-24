library ArrayHelper {
    function concat(address[] memory _inputArray, address _newItem) internal pure returns (address[] memory _newArray) {
        uint256 _inputArrayLength = _inputArray.length;
        _newArray = new address[](_inputArrayLength + 1);
        for (uint256 i = 0; i < _inputArrayLength; i++) {
            _newArray[i] = _inputArray[i];
        }
        _newArray[_inputArrayLength] = _newItem;
    }
}
