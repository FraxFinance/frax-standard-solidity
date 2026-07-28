// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Script } from "forge-std/Script.sol";
import { Strings } from "./@openzeppelin/contracts-5.4.0/utils/Strings.sol";

struct SafeTx {
    string name;
    address to;
    uint256 value;
    bytes data;
}

/// @notice Optional batch-level metadata. Every field is written into the `meta`
///         object of the Safe Transaction Builder file.
/// @param safe         The Safe the batch is meant for. Written as
///                     `meta.createdFromSafeAddress`. A batch is only a
///                     transaction once it is bound to a Safe, so recording it
///                     here keeps the artifact self-describing.
/// @param name         Batch name shown in the Safe UI.
/// @param description  Batch description shown in the Safe UI.
/// @param createdAt    Creation time in milliseconds. Left at 0 the output is
///                     byte-reproducible, so two runs of the same script produce
///                     identical files that can be diffed or hashed.
struct SafeBatchMeta {
    address safe;
    string name;
    string description;
    uint256 createdAt;
}

/// @title SafeTxHelper
/// @notice Writes a batch of transactions as a Safe{Wallet} Transaction Builder
///         JSON file, ready to be imported into the Safe UI.
///
///         The output follows the Transaction Builder schema, as defined by
///         `BatchFile` in safe-global/safe-react-apps:
///
///         {
///           "version": "1.0",
///           "chainId": "1",
///           "createdAt": 0,
///           "meta": { "name", "description", "createdFromSafeAddress", "txBuilderVersion" },
///           "transactions": [ { "to", "value", "data", "contractMethod", "contractInputsValues" } ]
///         }
contract SafeTxHelper is Script {
    /// @dev Reported as `meta.txBuilderVersion` so a consumer can tell which
    ///      writer produced the file.
    string internal constant TX_BUILDER_VERSION = "frax-standard-solidity";

    /// @notice Write `txs` to `path` without binding the batch to a Safe.
    /// @dev Prefer the overload taking a Safe address: without it the file cannot
    ///      say which Safe it belongs to, and the same batch is a different
    ///      transaction on a different Safe.
    function writeTxs(SafeTx[] memory txs, string memory path) public {
        writeTxs(txs, path, address(0));
    }

    /// @notice Write `txs` to `path`, recorded as created from `safe`.
    function writeTxs(SafeTx[] memory txs, string memory path, address safe) public {
        writeTxs(txs, path, SafeBatchMeta({ safe: safe, name: "Transactions Batch", description: "", createdAt: 0 }));
    }

    /// @notice Write `txs` to `path` with full control over the batch metadata.
    function writeTxs(SafeTx[] memory txs, string memory path, SafeBatchMeta memory meta) public {
        // Built by direct concatenation rather than `vm.serialize*`: the
        // transaction list is itself JSON, and serialising it as a string escapes
        // it, which then has to be un-escaped again. Emitting the bytes directly
        // keeps the output exact and needs no post-processing.
        string memory json = string.concat(
            "{\n",
            '  "version": "1.0",\n',
            '  "chainId": "',
            Strings.toString(block.chainid),
            '",\n',
            '  "createdAt": ',
            Strings.toString(meta.createdAt),
            ",\n",
            _metaJson(meta),
            ',\n  "transactions": [\n',
            _transactionsJson(txs),
            "\n  ]\n",
            "}\n"
        );

        vm.writeFile(path, json);
    }

    /// @dev The `meta` object. `createdFromSafeAddress` is omitted rather than
    ///      written as the zero address when no Safe was supplied, so a consumer
    ///      can tell "unbound" apart from "bound to 0x0".
    function _metaJson(SafeBatchMeta memory meta) internal view returns (string memory json) {
        json = string.concat(
            '  "meta": {\n    "name": "',
            _escape(meta.name),
            '",\n    "description": "',
            _escape(meta.description),
            '",\n'
        );

        if (meta.safe != address(0)) {
            json = string.concat(json, '    "createdFromSafeAddress": "', vm.toString(meta.safe), '",\n');
        }

        json = string.concat(json, '    "txBuilderVersion": "', TX_BUILDER_VERSION, '"\n  }');
    }

    /// @dev The `transactions` array. `contractMethod` and `contractInputsValues`
    ///      are null because the calldata is already encoded — the Safe UI only
    ///      uses those to re-encode a call from an ABI plus input values.
    function _transactionsJson(SafeTx[] memory txs) internal view returns (string memory json) {
        for (uint256 i = 0; i < txs.length; i++) {
            json = string.concat(
                json,
                '    {\n      "to": "',
                vm.toString(txs[i].to),
                '",\n      "value": "',
                Strings.toString(txs[i].value),
                '",\n      "data": "',
                vm.toString(txs[i].data),
                '",\n      "contractMethod": null,\n      "contractInputsValues": null\n    }',
                i + 1 < txs.length ? ",\n" : ""
            );
        }
    }

    /// @dev Escape the characters JSON forbids raw inside a string. Batch names
    ///      and descriptions are caller-supplied, and an unescaped quote would
    ///      produce a file the Safe UI cannot parse.
    function _escape(string memory input) internal pure returns (string memory output) {
        bytes memory data = bytes(input);
        for (uint256 i = 0; i < data.length; i++) {
            bytes1 char = data[i];
            if (char == '"') {
                output = string.concat(output, '\\"');
            } else if (char == "\\") {
                output = string.concat(output, "\\\\");
            } else if (char == "\n") {
                output = string.concat(output, "\\n");
            } else if (char == "\r") {
                output = string.concat(output, "\\r");
            } else if (char == "\t") {
                output = string.concat(output, "\\t");
            } else if (uint8(char) < 0x20) {
                output = string.concat(output, "\\u00", Strings.toHexString(uint8(char), 1));
            } else {
                output = string.concat(output, string(abi.encodePacked(char)));
            }
        }
    }
}
