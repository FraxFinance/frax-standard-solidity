// SPDX-License-Identifier: ISC
pragma solidity >=0.8.19;

import { Script } from "forge-std/Script.sol";
import { console2 as console } from "forge-std/Test.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

abstract contract BaseScript is Script {
    using Strings for *;

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

    function _updateEnv(address _address, bytes memory _constructorArgs, string memory _name) internal {
        string[] memory _inputs = new string[](8);
        _inputs[0] = "npx";
        _inputs[1] = "ts-node";
        _inputs[2] = "-T";
        _inputs[3] = "lib/frax-standard-solidity/script/updateEnv.ts";
        _inputs[4] = block.chainid.toString();
        _inputs[5] = _name;
        _inputs[6] = _address.toHexString();
        console.logBytes(_constructorArgs);
        vm.ffi(_inputs);
    }
}
