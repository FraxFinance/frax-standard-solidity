// SPDX-License-Identifier: ISC
pragma solidity ^0.8.0;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== StringsHelper ===========================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// ====================================================================

import { console2 as console } from "forge-std/Test.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";

library StringsHelper {
    using Strings for *;

    function padLeft(string memory _string, string memory _pad, uint256 _length) public pure returns (string memory) {
        while (bytes(_string).length < _length) {
            _string = string(abi.encodePacked(_pad, _string));
        }
        return _string;
    }

    function padRight(string memory _string, string memory _pad, uint256 _length) public pure returns (string memory) {
        while (bytes(_string).length < _length) {
            _string = string(abi.encodePacked(_string, _pad));
        }
        return _string;
    }

    function slice(string memory _string, uint256 _start, uint256 _end) public pure returns (string memory) {
        bytes memory _stringBytes = bytes(_string);
        bytes memory _result = new bytes(_end - _start);
        for (uint256 i = _start; i < _end; i++) {
            _result[i - _start] = _stringBytes[i];
        }
        return string(_result);
    }

    function trim(string memory _string) public pure returns (string memory) {
        bytes memory _stringBytes = bytes(_string);
        uint256 _start = 0;
        uint256 _end = _stringBytes.length - 1;
        for (uint256 i = 0; i < _stringBytes.length; i++) {
            if (_stringBytes[i] != " ") {
                _start = i;
                break;
            }
        }
        for (uint256 i = _stringBytes.length - 1; i >= 0; i--) {
            if (_stringBytes[i] != " ") {
                _end = i;
                break;
            }
        }
        return slice(_string, _start, _end + 1);
    }
}
