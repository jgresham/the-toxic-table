// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Player {
    address public playerAddress;
    bool public isRemoved;
    address public currentVotedPlayerToRemove;

    constructor(address _playerAddress) {
        playerAddress = _playerAddress;
        isRemoved = false;
    }

    function setCurrentVotedPlayerToRemove(address _playerToRemove) public {
        currentVotedPlayerToRemove = _playerToRemove;
    }

    function setIsRemoved(bool _isRemoved) public {
        isRemoved = _isRemoved;
    }
}
