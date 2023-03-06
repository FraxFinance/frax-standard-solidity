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
}
