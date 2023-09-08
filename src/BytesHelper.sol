// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { BytesLib } from "solidity-bytes-utils/contracts/BytesLib.sol";

library BytesHelper {
    function concat(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bytes memory) {
        return BytesLib.concat(_preBytes, _postBytes);
    }

    function concatStorage(bytes storage _preBytes, bytes memory _postBytes) internal {
        return BytesLib.concatStorage(_preBytes, _postBytes);
    }

    function slice(bytes memory _bytes, uint256 _start, uint256 _end) internal pure returns (bytes memory) {
        return BytesLib.slice(_bytes, _start, _end - _start);
    }

    function toAddress(bytes memory _bytes, uint256 _start) internal pure returns (address) {
        return BytesLib.toAddress(_bytes, _start);
    }

    function toUint256(bytes memory _bytes, uint256 _start) internal pure returns (uint256) {
        return BytesLib.toUint256(_bytes, _start);
    }

    function toBytes32(bytes memory _bytes, uint256 _start) internal pure returns (bytes32) {
        return BytesLib.toBytes32(_bytes, _start);
    }

    function equal(bytes memory _preBytes, bytes memory _postBytes) internal pure returns (bool) {
        return BytesLib.equal(_preBytes, _postBytes);
    }

    function equalStorage(bytes storage _preBytes, bytes memory _postBytes) internal view returns (bool) {
        return BytesLib.equalStorage(_preBytes, _postBytes);
    }
}
