// SPDX-License-Identifier: ISC
pragma solidity >=0.8.19;

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ============================= Logger ===============================
// ====================================================================
// Frax Finance: https://github.com/FraxFinance

// Primary Author
// Drake Evans: https://github.com/DrakeEvans

// ====================================================================

import { console2 as console } from "forge-std/Test.sol";
import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { NumberFormat } from "./NumberFormat.sol";
import { AddressHelper } from "./AddressHelper.sol";

library Logger {
    using Strings for *;
    using NumberFormat for *;
    using AddressHelper for *;

    uint64 internal constant FIFTY_BPS = 158_247_046;
    uint64 internal constant ONE_PERCENT = FIFTY_BPS * 2;
    uint64 internal constant ONE_BPS = FIFTY_BPS / 50;

    function logRate(string memory _string, uint256 _rate) public view {
        console.log(
            string(abi.encodePacked(_string, " BPS: ", (_rate / ONE_BPS).toString(), " (raw: ", _rate.toString(), ")"))
        );
    }

    function rate(string memory _string, uint256 _rate) public view {
        logRate(_string, _rate);
    }

    function logDecimal(string memory _string, uint256 _value, uint256 _precision) public view {
        string memory _valueString = _value.toDecimal(_precision);
        console.log(string(abi.encodePacked(_string, " ", _valueString, " (raw: ", _value.toString(), ")")));
    }

    function decimal(string memory _string, uint256 _value, uint256 _precision) public view {
        logDecimal(_string, _value, _precision);
    }

    function logPercent(string memory _string, uint256 _percent, uint256 _precision) public view {
        string memory _valueString = (_percent * 100).toDecimal(_precision);
        console.log(string(abi.encodePacked(_string, " ", _valueString, "%", " (raw: ", _percent.toString(), ")")));
    }

    function percent(string memory _string, uint256 _percent, uint256 _precision) public view {
        logPercent(_string, _percent, _precision);
    }

    function logScientific(string memory _string, uint256 _value) public view {
        string memory _valueString = _value.toScientific();
        console.log(string(abi.encodePacked(_string, " ", _valueString, " (raw: ", _value.toString(), ")")));
    }

    function scientific(string memory _string, uint256 _value) public view {
        logScientific(_string, _value);
    }

    function addressWithEtherscanLink(string memory _string, address _address) public view {
        console.log(
            string(abi.encodePacked(_string, " ", _address.toHexString(), " (", _address.toEtherscanLink(), ")"))
        );
    }
}
