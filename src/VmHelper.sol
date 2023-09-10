pragma solidity >=0.8.0;

import { CommonBase } from "forge-std/Base.sol";

contract VmHelper is CommonBase {
    struct MineBlocksResult {
        uint256 timeElapsed;
        uint256 blocksElapsed;
        uint256 currentTimestamp;
        uint256 currentBlockNumber;
    }

    function mineOneBlock() public returns (MineBlocksResult memory result) {
        uint256 timeElapsed = 12;
        uint256 blocksElapsed = 1;
        vm.warp(block.timestamp + timeElapsed);
        vm.roll(block.number + blocksElapsed);
        result.timeElapsed = timeElapsed;
        result.blocksElapsed = blocksElapsed;
        result.currentTimestamp = block.timestamp;
        result.currentBlockNumber = block.number;
    }

    // helper to move forward multiple blocks
    function mineBlocks(uint256 _blocks) public returns (MineBlocksResult memory result) {
        uint256 timeElapsed = (12 * _blocks);
        uint256 blocksElapsed = _blocks;
        vm.warp(block.timestamp + timeElapsed);
        vm.roll(block.number + blocksElapsed);

        result.timeElapsed = timeElapsed;
        result.blocksElapsed = blocksElapsed;
        result.currentTimestamp = block.timestamp;
        result.currentBlockNumber = block.number;
    }

    function mineBlocksBySecond(uint256 secondsElapsed) public returns (MineBlocksResult memory result) {
        uint256 timeElapsed = secondsElapsed;
        uint256 blocksElapsed = secondsElapsed / 12;
        vm.warp(block.timestamp + timeElapsed);
        vm.roll(block.number + blocksElapsed);

        result.timeElapsed = timeElapsed;
        result.blocksElapsed = blocksElapsed;
        result.currentTimestamp = block.timestamp;
        result.currentBlockNumber = block.number;
    }

    function mineBlocksToTimestamp(uint256 _timestamp) public returns (MineBlocksResult memory result) {
        uint256 timeElapsed = _timestamp - block.timestamp;
        uint256 blocksElapsed = timeElapsed / 12;
        vm.warp(_timestamp);
        vm.roll(block.number + blocksElapsed);

        result.timeElapsed = timeElapsed;
        result.blocksElapsed = blocksElapsed;
        result.currentTimestamp = block.timestamp;
        result.currentBlockNumber = block.number;
    }

    function labelAndDeal(address _address, string memory _label) public returns (address payable) {
        vm.label(_address, _label);
        vm.deal(_address, 1_000_000_000);
        return payable(_address);
    }
}
