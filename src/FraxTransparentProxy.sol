// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import { TransparentUpgradeableProxy } from "src/@openzeppelin/contracts-5.4.0/proxy/transparent/TransparentUpgradeableProxy.sol";

// ====================================================================
// |     ______                   _______                             |
// |    / _____________ __  __   / ____(_____  ____ _____  ________   |
// |   / /_  / ___/ __ `| |/_/  / /_  / / __ \/ __ `/ __ \/ ___/ _ \  |
// |  / __/ / /  / /_/ _>  <   / __/ / / / / / /_/ / / / / /__/  __/  |
// | /_/   /_/   \__,_/_/|_|  /_/   /_/_/ /_/\__,_/_/ /_/\___/\___/   |
// |                                                                  |
// ====================================================================
// ===================== FraxTransparentProxy =========================
// ====================================================================

contract FraxTransparentProxy is TransparentUpgradeableProxy {
    constructor(
        address _logic,
        address _initialAdmin,
        bytes memory _data
    ) TransparentUpgradeableProxy(_logic, _initialAdmin, _data) {}

    // ================================================================
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~ Extension ~~~~~~~~~~~~~~~~~~~~~~~~~~
    // ================================================================

    /// @notice Low level function to read arbitrary slots from the proxy
    /// @param slot  The slot to read
    /// @return data The bytes32 data that is stored on that slot
    /// @dev Ensure that `0x53e1edcb` does not result in selector clash on
    ///      The implementation contract
    function readArbitrary(bytes32 slot) public view returns (bytes32 data) {
        assembly {
            data := sload(slot)
        }
    }

    /// @notice Silence compiler warnings
    receive() external payable {
        _fallback();
    }
}
