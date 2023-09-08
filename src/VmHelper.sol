pragma solidity >=0.8.0;

import { CommonBase } from "forge-std/Base.sol";

contract VmHelper is CommonBase {
    struct MineOneBlockResult {
        uint256 timeElapsed;
        uint256 blocksElapsed;
        uint256 currentTimestamp;
        uint256 currentBlockNumber;
    }

    function mineOneBlock() public returns (MineOneBlockResult memory result) {
        uint256 timeElapsed = 12;
        uint256 blocksElapsed = 1;
        vm.warp(block.timestamp + timeElapsed);
        vm.roll(block.number + blocksElapsed);
        result.timeElapsed = timeElapsed;
        result.blocksElapsed = blocksElapsed;
        result.currentTimestamp = block.timestamp;
        result.currentBlockNumber = block.number;
    }

    struct MineBlocksResult {
        uint256 timeElapsed;
        uint256 blocksElapsed;
        uint256 currentTimestamp;
        uint256 currentBlockNumber;
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

    struct MineBlocksBySecondResult {
        uint256 timeElapsed;
        uint256 blocksElapsed;
        uint256 currentTimestamp;
        uint256 currentBlockNumber;
    }

    function mineBlocksBySecond(uint256 secondsElapsed) public returns (MineBlocksBySecondResult memory result) {
        uint256 timeElapsed = secondsElapsed;
        uint256 blocksElapsed = secondsElapsed / 12;
        vm.warp(block.timestamp + timeElapsed);
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
