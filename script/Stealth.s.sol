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
        address deployerAddress = vm.addr(deployerPrivateKey);

        vm.startBroadcast(deployerPrivateKey);
        Stealth stealthContract = new Stealth(deployerAddress);
        console.log("Stealth contract address: ", address(stealthContract));

        (bool success, ) = issuer.call{value: 10 ether}(
            abi.encodeWithSignature("apply(address)", address(stealthContract))
        );
        require(success, "Failed to apply");
        console.log("Applied to issuer");
        vm.stopBroadcast();
    }
}
