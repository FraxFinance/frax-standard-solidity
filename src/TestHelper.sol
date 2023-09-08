// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { Test } from "forge-std/Test.sol";

contract TestHelper is Test {
    // helper to move forward one block
    function mineOneBlock() public returns (uint256 _timeElapsed, uint256 _blocksElapsed) {
        _timeElapsed = 12;
        _blocksElapsed = 1;
        vm.warp(block.timestamp + _timeElapsed);
        vm.roll(block.number + _blocksElapsed);
    }

    // helper to move forward multiple blocks
    function mineBlocks(uint256 _blocks) public returns (uint256 _timeElapsed, uint256 _blocksElapsed) {
        _timeElapsed = (12 * _blocks);
        _blocksElapsed = _blocks;
        vm.warp(block.timestamp + _timeElapsed);
        vm.roll(block.number + _blocksElapsed);
    }
}
