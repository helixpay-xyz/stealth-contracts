// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";

import "./VICz.sol";

contract Stealth is VICz {
    /// @dev Event emitted when a user updates their registered stealth keys
    event StealthKeyChanged(
        bytes32 indexed registrant,
        address indexed authorizer,
        bytes composeKey
    );

    event Announcement(
        address indexed stealthAddress,
        uint16 indexed viewTag,
        bytes ephemeralPublicKey,
        bytes message
    );

    mapping(bytes32 => address) public authorizes;
    mapping(bytes32 => bytes) public keys;

    constructor(address owner) VICz(owner) {}

    function setStealthKeys(
        bytes32 _registrant,
        bytes memory _composeKey
    ) external {
        if (authorizes[_registrant] == address(0)) {
            authorizes[_registrant] = msg.sender;
        } else {
            require(
                authorizes[_registrant] == msg.sender,
                "StealthKeyRegistry: Unauthorized"
            );
        }

        keys[_registrant] = _composeKey;
        emit StealthKeyChanged(_registrant, msg.sender, _composeKey);
    }

    function announce(
        address _stealthAddress,
        uint16 _viewTag,
        bytes memory _ephemeralPublicKey,
        bytes memory _message
    ) external {
        emit Announcement(_stealthAddress, _viewTag, _ephemeralPublicKey, _message);
    }
}
