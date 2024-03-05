// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Player.sol";

contract Game {
    address public gameOwner;
    Player[] public players;

    constructor(address[] memory _playerAddresses) {
        gameOwner = msg.sender;
        if(_playerAddresses.length < 2) {
            revert("There must be at least 2 players to start the game");
        }
        for(uint i = 0; i < _playerAddresses.length; i++) {
            players.push(new Player(_playerAddresses[i]));
        }
    }

    function voteToRemovePlayer(address playerToRemove) public {
        // check if the msg.sender is an active player
        bool isMsgSenderAnActivePlayer = false;
        Player votingPlayer;
        for(uint i = 0; i < players.length; i++) {
            if(players[i].playerAddress() == msg.sender && players[i].isRemoved() == false) {
                isMsgSenderAnActivePlayer = true;
                votingPlayer = players[i];
                break;
            }
        }
        if(isMsgSenderAnActivePlayer == false) {
            revert("Only active players can vote to remove other players");
        }
        if(votingPlayer.playerAddress() == address(0)) {
            revert("Voting player not found");
        }

        // check if playerToRemove is an active player
        bool isPlayerToRemoveAnActivePlayer = false;
        for (uint i = 0; i < players.length; i++) {
            if(players[i].playerAddress() == playerToRemove && players[i].isRemoved() == false) {
                isPlayerToRemoveAnActivePlayer = true;
                break;
            }
        }
        if(isPlayerToRemoveAnActivePlayer == false) {
            revert("Player to remove is not an active player");
        }

        // player voting and player receiving the vote are both active players
        // now we can set the players vote to playerToRemove
        votingPlayer.setCurrentVotedPlayerToRemove(playerToRemove);

        // check to see if all active players have voted
        bool hasAllActivePlayersVoted = true;
        for (uint i = 0; i < players.length; i++) {
            if(players[i].isRemoved() == false && players[i].currentVotedPlayerToRemove() == address(0)){
                hasAllActivePlayersVoted = false;
                break;
            }
        }
    
        // if all players have voted, then remove the player with the most votes.
        // todo: separate this and following 2 pieces into a function and verify logic
        if(hasAllActivePlayersVoted == true) {
            address playerToRemove = players[0].playerAddress();
            uint playerToRemoveVotes = 0;
            for (uint i = 0; i < players.length; i++) {
                if(players[i].isRemoved() == false) {
                    uint votes = 0;
                    for (uint j = 0; j < players.length; j++) {
                        if(players[j].isRemoved() == false && players[j].currentVotedPlayerToRemove() == players[i].playerAddress()) {
                            votes++;
                        }
                    }
                    if(votes > playerToRemoveVotes) {
                        playerToRemove = players[i].playerAddress();
                        playerToRemoveVotes = votes;
                    }
                }
            }
            for (uint i = 0; i < players.length; i++) {
                if(players[i].playerAddress() == playerToRemove) {
                    players[i].setIsRemoved(true);
                    break;
                }
            }

            // Clear all players' votes
            for (uint i = 0; i < players.length; i++) {
                players[i].setCurrentVotedPlayerToRemove(address(0));
            }

            // Run win check

        }
    }
}
