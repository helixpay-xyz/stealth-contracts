// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "openzeppelin/token/ERC20/IERC20.sol";
import "openzeppelin/token/ERC20/utils/SafeERC20.sol";

import "./VICz.sol";

contract Stealth is VICz {
    /// @dev Event emitted when a user updates their registered stealth keys
    event StealthKeyChanged(
        bytes32 indexed registrant,
        uint256 spendingPubKeyPrefix,
        uint256 spendingPubKey,
        uint256 viewingPubKeyPrefix,
        uint256 viewingPubKey
    );

    event Announcement(
        address indexed receiver, // stealth address
        uint256 amount, // funds
        address indexed token, // token address or ETH placeholder
        bytes32 pkx, // ephemeral public key x coordinate
        bytes32 ciphertext // encrypted entropy and payload extension
    );

    mapping(bytes32 => address) public names;
    mapping(bytes32 => mapping(uint256 => uint256)) keys;

    constructor(address owner) VICz(owner) {}

    function setStealthKeys(
        bytes32 _registrant,
        uint256 _spendingPubKeyPrefix,
        uint256 _spendingPubKey,
        uint256 _viewingPubKeyPrefix,
        uint256 _viewingPubKey
    ) external {
        if (names[_registrant] == address(0)) {
            names[_registrant] = msg.sender;
        } else {
            require(
                names[_registrant] == msg.sender,
                "StealthKeyRegistry: Unauthorized"
            );
        }

        _setStealthKeys(
            _registrant,
            _spendingPubKeyPrefix,
            _spendingPubKey,
            _viewingPubKeyPrefix,
            _viewingPubKey
        );
    }

    function stealthKeys(bytes32 _registrant)
        external
        view
        returns (
            uint256 spendingPubKeyPrefix,
            uint256 spendingPubKey,
            uint256 viewingPubKeyPrefix,
            uint256 viewingPubKey
        )
    {
        if (keys[_registrant][0] != 0) {
            spendingPubKeyPrefix = 2;
            spendingPubKey = keys[_registrant][0];
        } else {
            spendingPubKeyPrefix = 3;
            spendingPubKey = keys[_registrant][1];
        }

        if (keys[_registrant][2] != 0) {
            viewingPubKeyPrefix = 2;
            viewingPubKey = keys[_registrant][2];
        } else {
            viewingPubKeyPrefix = 3;
            viewingPubKey = keys[_registrant][3];
        }

        return (
            spendingPubKeyPrefix,
            spendingPubKey,
            viewingPubKeyPrefix,
            viewingPubKey
        );
    }

    function _setStealthKeys(
        bytes32 _registrant,
        uint256 _spendingPubKeyPrefix,
        uint256 _spendingPubKey,
        uint256 _viewingPubKeyPrefix,
        uint256 _viewingPubKey
    ) internal {
        require(
            (_spendingPubKeyPrefix == 2 || _spendingPubKeyPrefix == 3) &&
                (_viewingPubKeyPrefix == 2 || _viewingPubKeyPrefix == 3),
            "StealthKeyRegistry: Invalid Prefix"
        );

        emit StealthKeyChanged(
            _registrant,
            _spendingPubKeyPrefix,
            _spendingPubKey,
            _viewingPubKeyPrefix,
            _viewingPubKey
        );

        // Shift the spending key prefix down by 2, making it the appropriate index of 0 or 1
        _spendingPubKeyPrefix -= 2;

        // Ensure the opposite prefix indices are empty
        delete keys[_registrant][1 - _spendingPubKeyPrefix];
        delete keys[_registrant][5 - _viewingPubKeyPrefix];

        // Set the appropriate indices to the new key values
        keys[_registrant][_spendingPubKeyPrefix] = _spendingPubKey;
        keys[_registrant][_viewingPubKeyPrefix] = _viewingPubKey;
    }

    function transfer(
        address _receiver,
        address _tokenAddr,
        uint256 _amount,
        bytes32 _pkx, // ephemeral public key x coordinate
        bytes32 _ciphertext
    ) external payable {
        if (_tokenAddr != address(0)) {
            SafeERC20.safeTransferFrom(
                IERC20(_tokenAddr),
                msg.sender,
                _receiver,
                _amount
            );
        }

        payable(_receiver).transfer(msg.value); // forward ETH
        emit Announcement(_receiver, _amount, _tokenAddr, _pkx, _ciphertext);
    }
}
