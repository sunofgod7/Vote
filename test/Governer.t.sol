// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {Erc20VoteProject} from "../src/VoteToken.sol";
import {MyGovernor} from "../src/Governer.sol";

contract MyGovernorTest is Test {
    Erc20VoteProject public vote;
    MyGovernor public governer;

    address alice = address(0x5E11E7);

    function setUp() public {
        vote = new Erc20VoteProject();
        governer = new MyGovernor(vote);
    }

    function test_owner() public {
        vm.startPrank(governer.owner());
        assertEq(governer.owner(), vote.owner());
        vm.stopPrank();
    }

    function test_VotingDelay() public {
        vm.startPrank(governer.owner());
        uint pVotingDelay = governer.votingDelay();
        governer.setVotingDelay(12);
        uint newVotingDelay = governer.votingDelay();
        assertEq(pVotingDelay, 0);
        assertEq(newVotingDelay, 12);
        vm.stopPrank();
    }

    function test_VotingPeriod() public {
        vm.startPrank(governer.owner());
        uint pVotingPeriod = governer.votingPeriod();
        governer.setVotingPeriod(1000000);
        uint newVotingPeriod = governer.votingPeriod();
        assertEq(pVotingPeriod, 50400);
        assertEq(newVotingPeriod, 1000000);
        vm.stopPrank();
    }
}
