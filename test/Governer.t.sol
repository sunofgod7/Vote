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

    function test_createProposal() public {
        vm.startPrank(governer.owner());

        address[] memory targets = new address[](1);
        targets[0] = address(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);

        uint256[] memory values = new uint256[](1);
        values[0] = uint256(0);

        bytes[] memory calldatas = new bytes[](1);
        calldatas[
            0
        ] = hex"40c10f19000000000000000000000000dd4c825203f97984e7867f11eecc813a036089d1";
        bytes32 descriptionHash = 0x2b3d6e1302ebbdbd512643bb0f99b6134d2df5100c1a96f05862d67c20435ab6;
        governer.createProposal(
            targets,
            values,
            calldatas,
            "This is a test Proposal",
            1000
        );

        uint proposalId = governer.hashProposal(
            targets,
            values,
            calldatas,
            descriptionHash
        );
        uint clock = governer.clock();
        uint votingPeriod = governer.votingPeriod();
        uint deadline = governer.proposalDeadline(proposalId);
        uint proposalSnapshot = governer.proposalSnapshot(proposalId);
        address proposalProposer = governer.proposalProposer(proposalId);
        assertEq(
            proposalId,
            50408225053052276784035196670121134426348446480010563151085965337434742180671
        );
        assertEq(deadline, clock + votingPeriod);
        assertEq(proposalSnapshot, clock);
        assertEq(proposalProposer, governer.owner());

        vm.stopPrank();
    }
}
