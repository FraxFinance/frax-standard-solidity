// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { console2 as console } from "forge-std/Test.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { StringsHelper } from "./StringsHelper.sol";

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ========================== NumberFormat ============================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// ====================================================================

library NumberFormat {
    using Strings for *;
    using StringsHelper for *;

    function toDecimal(uint256 _value, uint256 _precision) public pure returns (string memory) {
        uint256 _decimals = bytes(Strings.toString(_precision)).length - 1;
        uint256 _integer = _value >= _precision ? _value / _precision : 0;
        string memory _decimalString = (_value - (_integer * _precision)).toString().padLeft("0", _decimals);
        return string(abi.encodePacked(_integer.toString(), ".", _decimalString));
    }

    function toScientific(uint256 _value) public pure returns (string memory) {
        uint256 _decimals = bytes(Strings.toString(_value)).length - 1;
        uint256 _precision = 10 ** _decimals;
        uint256 _integer = _value >= _precision ? _value / _precision : 0;
        string memory _decimalString = (_value - (_integer * _precision)).toString().padLeft("0", _decimals);
        bytes memory _decimalBytes = bytes(_decimalString);
        // find index of first non-zero digit starting from the right
        uint256 _firstNonZeroIndex;
        for (uint256 i = _decimalBytes.length - 1; i > 0; i--) {
            if (_decimalBytes[i] != "0") {
                _firstNonZeroIndex = i;
                break;
            }
        }
        if (_firstNonZeroIndex == 0) {
            return string(abi.encodePacked(_integer.toString(), "e", _decimals.toString()));
        } else {
            _decimalString = _decimalString.slice(0, _firstNonZeroIndex + 1);
            return string(abi.encodePacked(_integer.toString(), ".", _decimalString, "e", _decimals.toString()));
        }
    }
}
