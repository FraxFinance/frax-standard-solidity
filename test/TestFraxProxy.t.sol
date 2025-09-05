// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";
import { IERC20 } from "src/@openzeppelin/contracts-5.4.0/token/ERC20/IERC20.sol";
import { FraxTransparentProxy } from "src/FraxTransparentProxy.sol";

contract TestFraxTransparentProxy is FraxTest {
    address instance;
    FraxTransparentProxy frxUsdProxy;
    IERC20 frxUsd;

    function setUp() public {
        vm.createSelectFork("https://rpc.frax.com", 16_557_873);
        vm.etch(
            address(0xC2A4), /// The Unicode character '¤' encoded in UTF-8 and represented as hex
            hex"11"
        );
        instance = address(new FraxTransparentProxy(address(0xC2A4), address(0xC2A4), hex""));
        vm.etch(0xFc00000000000000000000000000000000000001, instance.code);
        frxUsdProxy = FraxTransparentProxy(payable(0xFc00000000000000000000000000000000000001));
        frxUsd = IERC20(0xFc00000000000000000000000000000000000001);
    }

    function testReadImplementationSlot() public view {
        bytes32 impl = frxUsdProxy.readArbitrary(IMPLEMENTATION_SLOT);
        assertEq({
            right: address(uint160(uint256(impl))),
            left: 0x00000aFb5e62fd81bC698E418dBfFE5094cB38E0,
            err: "// THEN: Implementation not as expected"
        });
    }

    function testReadAdminSlot() public view {
        bytes32 admin = frxUsdProxy.readArbitrary(ADMIN_SLOT);
        console.logBytes32(admin);
        assertEq({
            right: address(uint160(uint256(admin))),
            left: 0xfC0000000000000000000000000000000000000a,
            err: "// THEN: Admin not as expected"
        });
    }

    function testReadBalanceData() public view {
        /// Derive the balance slot
        bytes32 balanceSlot = keccak256(abi.encode(0x31562ae726AFEBe25417df01bEdC72EF489F45b3, 0));
        bytes32 balance = frxUsdProxy.readArbitrary(balanceSlot);
        assertEq({ right: uint256(balance), left: 879.253786510845295473e18, err: "// THEN: balance not as expected" });
    }
}
