// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "forge-std/Test.sol";
import "../src/Game.sol";

contract GameTest is Test {
    // Game public game;

    // function setUp() public {
    //     game = new Game();
    // }

    function testFail_CreateGameWithOneAddressFixedArray() public {
        address[] memory playerAddresses = new address[](1);
        playerAddresses[0] = address(0x123);
        new Game(playerAddresses);
    }

    function testRevert_CreateGameWithOneAddressFixedArray() public {
        vm.expectRevert(bytes("There must be at least 2 players to start the game"));
        address[] memory playerAddresses = new address[](1);
        playerAddresses[0] = address(0x123);
        new Game(playerAddresses);
    }
    
    // function testFail_CreateGameWithOneAddress() public {
    //     address[] storage playerAddresses;
    //     playerAddresses.push(address(123));
    //     new Game(playerAddresses);
    // }

    // function test_CreateGameWithTwoAddresses() public {
    //     address[] storage playerAddresses;
    //     playerAddresses[0] = address(123);
    //     playerAddresses[1] = address(1234);
    //     new Game(playerAddresses);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     counter.setNumber(x);
    //     assertEq(counter.number(), x);
    // }
}
