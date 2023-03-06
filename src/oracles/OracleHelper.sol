// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { Vm } from "forge-std/Test.sol";

library OracleHelper {
    function setDecimals(AggregatorV3Interface _oracle, uint8 _decimals, Vm vm) public {
        vm.mockCall(
            address(_oracle),
            abi.encodeWithSelector(AggregatorV3Interface.decimals.selector),
            abi.encode(_decimals)
        );
    }

    /// @notice The ```setPrice``` function uses a numerator and denominator value to set a price using the number of decimals from the oracle itself
    /// @dev Remember the units here, quote per asset i.e. USD per ETH for the ETH/USD oracle
    /// @param _oracle The oracle to mock
    /// @param numerator The numerator of the price
    /// @param denominator The denominator of the price
    /// @param vm The vm from forge
    function setPrice(
        AggregatorV3Interface _oracle,
        uint256 numerator,
        uint256 denominator,
        uint256 _lastUpdatedAt,
        Vm vm
    ) public returns (int256 _price) {
        _price = int256((numerator * 10 ** _oracle.decimals()) / denominator);
        vm.mockCall(
            address(_oracle),
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(uint80(0), _price, 0, _lastUpdatedAt, uint80(0))
        );
    }
}
