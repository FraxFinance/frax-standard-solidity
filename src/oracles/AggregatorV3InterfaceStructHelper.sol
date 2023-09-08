// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library AggregatorV3InterfaceStructHelper {
    struct GetRoundDataReturn {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    function __getRoundData(
        AggregatorV3Interface _aggregatorV3,
        uint80 _roundId
    ) internal view returns (GetRoundDataReturn memory _return) {
        (_return.roundId, _return.answer, _return.startedAt, _return.updatedAt, _return.answeredInRound) = _aggregatorV3
            .getRoundData(_roundId);
    }

    struct LatestRoundDataReturn {
        uint80 roundId;
        int256 answer;
        uint256 startedAt;
        uint256 updatedAt;
        uint80 answeredInRound;
    }

    function __latestRoundData(
        AggregatorV3Interface _aggregatorV3
    ) internal view returns (LatestRoundDataReturn memory _return) {
        (_return.roundId, _return.answer, _return.startedAt, _return.updatedAt, _return.answeredInRound) = _aggregatorV3
            .latestRoundData();
    }
}
