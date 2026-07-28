// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";
import { SafeTxHelper, SafeTx, SafeBatchMeta } from "../src/SafeTxHelper.sol";

contract TestSafeTxHelper is FraxTest {
    SafeTxHelper internal helper;

    string internal constant OUT_DIR = "test/.tmp";

    function setUp() public {
        helper = new SafeTxHelper();
        vm.createDir(OUT_DIR, true);
    }

    function _path(string memory name) internal pure returns (string memory) {
        return string.concat(OUT_DIR, "/", name, ".json");
    }

    function _twoTxs() internal pure returns (SafeTx[] memory txs) {
        txs = new SafeTx[](2);
        txs[0] = SafeTx({
            name: "approve",
            to: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            value: 0,
            data: abi.encodeWithSignature("approve(address,uint256)", address(0xBEEF), 0)
        });
        txs[1] = SafeTx({
            name: "transfer",
            to: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            value: 1 ether,
            data: abi.encodeWithSignature("transfer(address,uint256)", address(0xDEAD), 1e6)
        });
    }

    /// @notice The file must match the Transaction Builder schema: `chainId` is a
    ///         string, `createdAt` a number, and every transaction carries the
    ///         five keys the Safe UI reads.
    function testWritesTransactionBuilderSchema() public {
        SafeTx[] memory txs = _twoTxs();
        string memory path = _path("schema");
        helper.writeTxs(txs, path, address(0xABCD));

        string memory json = vm.readFile(path);

        assertEq(vm.parseJsonString(json, ".version"), "1.0");
        assertEq(vm.parseJsonString(json, ".chainId"), Strings.toString(block.chainid));
        assertEq(vm.parseJsonUint(json, ".createdAt"), 0);
        assertEq(vm.parseJsonString(json, ".meta.name"), "Transactions Batch");
        assertEq(vm.parseJsonString(json, ".meta.description"), "");

        assertEq(vm.parseJsonAddress(json, ".transactions[0].to"), txs[0].to);
        assertEq(vm.parseJsonString(json, ".transactions[0].value"), "0");
        assertEq(vm.parseJsonBytes(json, ".transactions[0].data"), txs[0].data);

        assertEq(vm.parseJsonAddress(json, ".transactions[1].to"), txs[1].to);
        assertEq(vm.parseJsonString(json, ".transactions[1].value"), "1000000000000000000");
        assertEq(vm.parseJsonBytes(json, ".transactions[1].data"), txs[1].data);

        assertTrue(vm.keyExistsJson(json, ".transactions[1].contractMethod"), "contractMethod key");
        assertTrue(vm.keyExistsJson(json, ".transactions[1].contractInputsValues"), "inputs key");
    }

    /// @notice The Safe address is what binds a batch to a transaction; without it
    ///         the same file is a different transaction on every Safe.
    function testRecordsTheSafeAddress() public {
        address safe = 0x111CEEee040739fD91D29C34C33E6B3E112F2177;
        string memory path = _path("bound");
        helper.writeTxs(_twoTxs(), path, safe);

        assertEq(vm.parseJsonAddress(vm.readFile(path), ".meta.createdFromSafeAddress"), safe);
    }

    /// @notice With no Safe, the key is absent rather than zero — "unbound" and
    ///         "bound to 0x0" must not look the same.
    function testOmitsSafeAddressWhenUnbound() public {
        string memory path = _path("unbound");
        helper.writeTxs(_twoTxs(), path);

        assertFalse(vm.keyExistsJson(vm.readFile(path), ".meta.createdFromSafeAddress"), "should be absent");
    }

    /// @notice Same inputs, same bytes. A batch you cannot reproduce is a batch you
    ///         cannot review by diffing or pin by hash.
    function testOutputIsReproducible() public {
        string memory a = _path("repro-a");
        string memory b = _path("repro-b");

        helper.writeTxs(_twoTxs(), a, address(0xABCD));
        vm.warp(block.timestamp + 3 days);
        helper.writeTxs(_twoTxs(), b, address(0xABCD));

        assertEq(keccak256(bytes(vm.readFile(a))), keccak256(bytes(vm.readFile(b))));
    }

    /// @notice An explicit timestamp is still available for anyone who wants one.
    function testHonoursAnExplicitCreatedAt() public {
        string memory path = _path("stamped");
        helper.writeTxs(
            _twoTxs(),
            path,
            SafeBatchMeta({ safe: address(0xABCD), name: "Batch", description: "", createdAt: 1760128999000 })
        );

        assertEq(vm.parseJsonUint(vm.readFile(path), ".createdAt"), 1760128999000);
    }

    /// @notice Names and descriptions are caller-supplied, so quotes and backslashes
    ///         have to survive into valid JSON rather than break the file.
    function testEscapesMetadataStrings() public {
        string memory name = 'Upgrade "V110" \\ destinations';
        string memory description = "line one\nline two\ttabbed";
        string memory path = _path("escaped");

        helper.writeTxs(
            _twoTxs(),
            path,
            SafeBatchMeta({ safe: address(0xABCD), name: name, description: description, createdAt: 0 })
        );

        string memory json = vm.readFile(path);
        assertEq(vm.parseJsonString(json, ".meta.name"), name);
        assertEq(vm.parseJsonString(json, ".meta.description"), description);
    }

    function testWritesASingleTransaction() public {
        SafeTx[] memory txs = new SafeTx[](1);
        txs[0] = SafeTx({ name: "noop", to: address(0xFEED), value: 0, data: "" });

        string memory path = _path("single");
        helper.writeTxs(txs, path, address(0xABCD));

        string memory json = vm.readFile(path);
        assertEq(vm.parseJsonAddress(json, ".transactions[0].to"), address(0xFEED));
        assertEq(vm.parseJsonString(json, ".transactions[0].data"), "0x");
        assertFalse(vm.keyExistsJson(json, ".transactions[1].to"), "only one transaction");
    }

    function testWritesAnEmptyBatch() public {
        string memory path = _path("empty");
        helper.writeTxs(new SafeTx[](0), path, address(0xABCD));

        assertFalse(vm.keyExistsJson(vm.readFile(path), ".transactions[0].to"), "no transactions");
    }
}
