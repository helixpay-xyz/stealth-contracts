// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "forge-std/console.sol";

import "../src/Stealth.sol";

contract StealthScript is Script {
    address issuer = 0x8c0faeb5C6bEd2129b8674F262Fd45c4e9468bee;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPrivateKey);
        (bool success, ) = issuer.call{value: 10 ether}(
            abi.encodeWithSignature("apply(address)", address(0x5715729dcfFc6717eb53D4E4446322368d4cF7F3))
        );
        require(success, "Failed to apply");
        console.log("Applied to issuer");
        vm.stopBroadcast();
    }
}
