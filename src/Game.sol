// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./Player.sol";

contract Game {
    address public gameOwner;
    Player[] public players;

    event Winner(Player winner);

    constructor(address[] memory playerAddresses) {
        gameOwner = msg.sender;
        if(playerAddresses.length < 2) {
            revert("There must be at least 2 players to start the game");
        }
        for(uint i = 0; i < playerAddresses.length; i++) {
            players.push(new Player(playerAddresses[i]));
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
            // Shuffling the players introduces randomness to any tie votes between players with an equal number of votes
            Player[] memory shuffledPlayers = psuedoShuffle(players);
            address currentPlayerToRemove = shuffledPlayers[0].playerAddress();
            uint currentPlayerToRemoveVotes = 0;
            for (uint i = 0; i < players.length; i++) {
                if(shuffledPlayers[i].isRemoved() == false) {
                    // Count votes for the current player
                    uint votes = 0;
                    for (uint j = 0; j < players.length; j++) {
                        if(shuffledPlayers[j].isRemoved() == false && shuffledPlayers[j].currentVotedPlayerToRemove() == shuffledPlayers[i].playerAddress()) {
                            votes++;
                        }
                    }
                    if(votes > currentPlayerToRemoveVotes) {
                        currentPlayerToRemove = shuffledPlayers[i].playerAddress();
                        currentPlayerToRemoveVotes = votes;
                    }
                }
            }
            for (uint i = 0; i < players.length; i++) {
                if(players[i].playerAddress() == currentPlayerToRemove) {
                    players[i].setIsRemoved(true);
                    break;
                }
            }

            // Clear all players' votes
            for (uint i = 0; i < players.length; i++) {
                players[i].setCurrentVotedPlayerToRemove(address(0));
            }

            // Run win check - one player left
            uint unremovedPlayers = 0;
            Player unremovedPlayer;
            for (uint i = 0; i < players.length; i++) {
                if(players[i].isRemoved() == false) {
                    unremovedPlayers++;
                    unremovedPlayer = players[i];
                }
            }
            if(unremovedPlayers == 1) {
                // winner!
                emit Winner(unremovedPlayer);
            }

        }
    }

    function psuedoShuffle(Player[] memory array) public view returns (Player[] memory) {
        for (uint256 i = 0; i < array.length; i++) {
            uint256 n = i + uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, i))) % (array.length - i);
            Player temp = array[n];
            array[n] = array[i];
            array[i] = temp;
        }
        return array;
    }
}
