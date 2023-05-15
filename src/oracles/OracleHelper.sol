// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import { Vm } from "forge-std/Test.sol";
import { AggregatorV3InterfaceStructHelper } from "./AggregatorV3InterfaceStructHelper.sol";

library OracleHelper {
    using AggregatorV3InterfaceStructHelper for AggregatorV3Interface;

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

    function setPrice(
        AggregatorV3Interface _oracle,
        uint256 price_,
        uint256 _lastUpdatedAt,
        Vm vm
    ) public returns (int256 _price) {
        _price = int256(price_);
        vm.mockCall(
            address(_oracle),
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(uint80(0), _price, 0, _lastUpdatedAt, uint80(0))
        );
    }

    function setPrice(
        AggregatorV3Interface _oracle,
        int256 price_,
        uint256 _lastUpdatedAt,
        Vm vm
    ) public returns (int256 _price) {
        _price = int256(price_);
        vm.mockCall(
            address(_oracle),
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(uint80(0), _price, 0, _lastUpdatedAt, uint80(0))
        );
    }

    function setPrice(AggregatorV3Interface _oracle, uint256 price_, Vm vm) public returns (int256 _price) {
        uint256 _updatedAt = _oracle.__latestRoundData().updatedAt;
        _price = int256(price_);
        vm.mockCall(
            address(_oracle),
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(uint80(0), _price, 0, _updatedAt, uint80(0))
        );
    }

    function setPriceWithE18Param(
        AggregatorV3Interface _oracle,
        uint256 price_,
        Vm vm
    ) public returns (int256 returnPrice) {
        uint256 _updatedAt = _oracle.__latestRoundData().updatedAt;
        uint256 _decimals = _oracle.decimals();
        price_ = (price_ * 10 ** _decimals) / 1e18;
        returnPrice = int256(price_);
        vm.mockCall(
            address(_oracle),
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(uint80(0), returnPrice, 0, _updatedAt, uint80(0))
        );
    }

    function setUpdatedAt(AggregatorV3Interface _oracle, uint256 _updatedAt, Vm vm) public returns (int256 _price) {
        int256 _price = _oracle.__latestRoundData().answer;
        vm.mockCall(
            address(_oracle),
            abi.encodeWithSelector(AggregatorV3Interface.latestRoundData.selector),
            abi.encode(uint80(0), _price, 0, _updatedAt, uint80(0))
        );
    }
}
