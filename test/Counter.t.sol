// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {Erc20VoteProject} from "../src/VoteToken.sol";

contract Erc20VoteTest is Test {
    Erc20VoteProject public vote;
    address alice = address(0x5E11E7);

    function setUp() public {
        vote = new Erc20VoteProject(msg.sender);
    }

    function test_delegate() public {
        vm.startPrank(vote.owner());
        vote.delegate(address(0x5E11E7));
        address delegates = vote.delegates(vote.owner());
        assertEq(delegates, address(0x5E11E7));
        vm.stopPrank();
    }

    function test_mintSelfDelegate() public {
        vm.startPrank(vote.owner());
        vote.mint(address(0x5E11E7), 1000);
        address delegates = vote.delegates(address(0x5E11E7));
        assertEq(delegates, address(0x5E11E7));
        vm.stopPrank();
    }

    function test_selfDelegateCondition() public {
        vm.startPrank(address(0x5E11E7));
        vote.delegate(address(0x5E11E8));
        vm.stopPrank();
        vm.startPrank(vote.owner());
        vote.mint(address(0x5E11E7), 1000);
        address delegates = vote.delegates(address(0x5E11E7));
        assertEq(delegates, address(0x5E11E8));
        vm.stopPrank();
    }

    function test_transferDelegate() public {
        vm.startPrank(vote.owner());
        vote.mint(vote.owner(), 1000);
        vote.transfer(address(0x5E11E9), 100);
        address delegates = vote.delegates(address(0x5E11E9));
        assertEq(delegates, address(0x5E11E9));
        vm.stopPrank();
    }
}
