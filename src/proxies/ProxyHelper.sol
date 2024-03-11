// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Proxy } from "./Proxy.sol";

contract ProxyHelper {
    function deployProxyAndCall(
        address _owner,
        address _implementation,
        bytes32 _salt,
        bytes4 _functionSignature,
        bytes memory _encodedArguments
    ) external returns (address) {
        Proxy proxy = new Proxy{ salt: _salt }({ _owner: msg.sender });
        bytes memory data = abi.encode(_functionSignature, _encodedArguments);
        proxy.upgradeToAndCall({ _implementation: _implementation, _data: data });
        proxy.initialize(_owner);

        return address(proxy);
    }
}
