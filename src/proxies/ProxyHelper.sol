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
        Proxy proxy = new Proxy{ salt: _salt }();
        bytes memory data = abi.encode(_functionSignature, _encodedArguments);
        proxy.upgradeToAndCall({ _implementation: _implementation, _data: data });
        if (_owner != msg.sender) {
            proxy.changeAdmin(_owner);
        }

        return address(proxy);
    }
}
