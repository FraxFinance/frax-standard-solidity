// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { stdJson } from "forge-std/StdJson.sol";
import { Strings } from "src/@openzeppelin/contracts-5.4.0/utils/Strings.sol";

struct SafeTx {
    string name;
    address to;
    uint256 value;
    bytes data;
}

contract SafeTxHelper is Script {
    using stdJson for string;

    function writeTxs(SafeTx[] memory txs, string memory path) public {
        string memory json = "json";
        // Default values
        vm.serializeString(json, "version", "1.0");
        vm.serializeUint(json, "chainId", block.chainid);
        vm.serializeUint(json, "createdAt", block.timestamp * 1000);

        string memory safeTxs = "[";
        for (uint256 i = 0; i < txs.length; i++) {
            if (i != 0) {
                safeTxs = string.concat(safeTxs, ",");
            }

            string memory transaction = "tx";
            vm.serializeAddress(transaction, "to", txs[i].to);
            vm.serializeString(transaction, "value", Strings.toString(txs[i].value));
            vm.serializeInt(transaction, "operation", 0);
            string memory serializedTx = vm.serializeBytes(transaction, "data", txs[i].data);

            safeTxs = string.concat(safeTxs, serializedTx);
        }
        safeTxs = string.concat(safeTxs, "]");

        string memory meta = "meta";
        vm.serializeString(meta, "name", "Transactions Batch");
        string memory serializedMeta = vm.serializeString(meta, "description", "");

        vm.serializeString(json, "transactions", safeTxs);
        string memory finalJson = vm.serializeString(json, "meta", serializedMeta);

        vm.writeJson({ json: finalJson, path: path });

        string[] memory commands = new string[](4);
        // re-used commands to find-replace
        commands[0] = "sed";
        commands[1] = "-i";
        commands[3] = path;

        // Remove all backslashes
        commands[2] = "s/\\\\//g";
        vm.ffi(commands);

        // Replace `"[` with `[`]
        commands[2] = 's/\\"\\[/\\[/g';
        vm.ffi(commands);

        // Replace `]"` with `]`
        commands[2] = 's/\\]\\"/\\]/g';
        vm.ffi(commands);
    }
}
