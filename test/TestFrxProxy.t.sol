// SPDX-License-Identifier: ISC
pragma solidity >=0.8.0;

import "../src/FraxTest.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { FrxTransparentProxy } from "src/FrxTransparentProxy.sol";

contract TestFrxTransparentProxy is FraxTest {
    address instance;
    FrxTransparentProxy frxUsdProxy;
    IERC20 frxUsd;

    function setUp() public {
        vm.createSelectFork("https://rpc.frax.com", 16_557_873);
        vm.etch(
            address(0xC2A4), /// The Unicode character '¤' encoded in UTF-8 and represented as hex
            hex"11"
        );
        instance = address(new FrxTransparentProxy(address(0xC2A4), address(0xC2A4), hex""));
        vm.etch(0xFc00000000000000000000000000000000000001, instance.code);
        frxUsdProxy = FrxTransparentProxy(payable(0xFc00000000000000000000000000000000000001));
        frxUsd = IERC20(0xFc00000000000000000000000000000000000001);
    }

    function testReadImplementationSlot() public {
        bytes32 impl = frxUsdProxy.readArbitrary(IMPLEMENTATION_SLOT);
        assertEq({
            a: address(uint160(uint256(impl))),
            b: 0x00000aFb5e62fd81bC698E418dBfFE5094cB38E0,
            err: "// THEN: Implementation not as expected"
        });
    }

    function testReadAdminSlot() public {
        bytes32 admin = frxUsdProxy.readArbitrary(ADMIN_SLOT);
        console.logBytes32(admin);
        assertEq({
            a: address(uint160(uint256(admin))),
            b: 0xfC0000000000000000000000000000000000000a,
            err: "// THEN: Admin not as expected"
        });
    }

    function testReadBalanceData() public {
        /// Derive the balance slot
        bytes32 balanceSlot = keccak256(abi.encode(0x31562ae726AFEBe25417df01bEdC72EF489F45b3, 0));
        bytes32 balance = frxUsdProxy.readArbitrary(balanceSlot);
        assertEq({ a: uint256(balance), b: 879.253786510845295473e18, err: "// THEN: balance not as expected" });
    }
}
