// SPDX-License-Identifier: ISC
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";

abstract contract BaseScript is Script {
    address internal deployer;
    uint256 internal privateKey;

    function setUp() public virtual {
        privateKey = vm.envUint("PK");
        deployer = vm.rememberKey(privateKey);
    }

    modifier broadcaster() {
        vm.startBroadcast(deployer);
        _;
        vm.stopBroadcast();
    }
}
