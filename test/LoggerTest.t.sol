// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";
import "../src/Logger.sol";

contract LoggerTest is FraxTest {
    function testAddressWithLink() public pure {
        address _address = address(0);
        Logger.addressWithEtherscanLink("test", _address);
    }
}
