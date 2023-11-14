// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console2} from "forge-std/Test.sol";
import {Erc20VoteProject} from "../src/VoteToken.sol";
import {MyGovernor} from "../src/Governer.sol";

contract MyGovernorTest is Test {
    Erc20VoteProject public vote;
    MyGovernor public governor;

    address alice = address(0x5E11E7);
    address bob = address(0x5E11E8);

    address joe = address(0x5E11E9);

    function setUp() public {
        vote = new Erc20VoteProject();
        governor = new MyGovernor(vote);
    }

    function test_owner() public {
        vm.startPrank(governor.owner());
        assertEq(governor.owner(), vote.owner());
        vm.stopPrank();
    }

    function test_votingDelay() public {
        vm.startPrank(governor.owner());
        uint256 pVotingDelay = governor.votingDelay();
        governor.setVotingDelay(12);
        uint256 newVotingDelay = governor.votingDelay();
        assertEq(pVotingDelay, 0);
        assertEq(newVotingDelay, 12);
        vm.stopPrank();
    }

    function test_votingPeriod() public {
        vm.startPrank(governor.owner());
        uint256 pVotingPeriod = governor.votingPeriod();
        governor.setVotingPeriod(1000000);
        uint256 newVotingPeriod = governor.votingPeriod();
        assertEq(pVotingPeriod, 50400);
        assertEq(newVotingPeriod, 1000000);
        vm.stopPrank();
    }

    function test_createProposal() public {
        vm.startPrank(governor.owner());

        address[] memory targets = new address[](1);
        targets[0] = address(0xd8b934580fcE35a11B58C6D73aDeE468a2833fa8);

        uint256[] memory values = new uint256[](1);
        values[0] = uint256(0);

        bytes[] memory calldatas = new bytes[](1);
        calldatas[
            0
        ] = hex"40c10f19000000000000000000000000dd4c825203f97984e7867f11eecc813a036089d1";
        bytes32 descriptionHash = 0x2b3d6e1302ebbdbd512643bb0f99b6134d2df5100c1a96f05862d67c20435ab6;
        governor.createProposal(
            targets,
            values,
            calldatas,
            "This is a test Proposal",
            1000
        );

        uint256 proposalId = governor.hashProposal(
            targets,
            values,
            calldatas,
            descriptionHash
        );
        uint256 clock = governor.clock();
        uint256 votingPeriod = governor.votingPeriod();
        uint256 deadline = governor.proposalDeadline(proposalId);
        uint256 proposalSnapshot = governor.proposalSnapshot(proposalId);
        address proposalProposer = governor.proposalProposer(proposalId);
        assertEq(
            proposalId,
            50408225053052276784035196670121134426348446480010563151085965337434742180671
        );
        assertEq(deadline, clock + votingPeriod);
        assertEq(proposalSnapshot, clock);
        assertEq(proposalProposer, governor.owner());

        vm.stopPrank();
    }

    function test_castVote() public {
        vm.startPrank(governor.owner());
        vote.mint(alice, 1000);
        vote.mint(bob, 500);
        vm.roll(block.number + 1);
        address[] memory targets = new address[](1);
        targets[0] = address(vote);

        uint256[] memory values = new uint256[](1);
        values[0] = uint256(0);

        bytes[] memory calldatas = new bytes[](1);
        calldatas[
            0
        ] = hex"40c10f19000000000000000000000000dd4c825203f97984e7867f11eecc813a036089d1";
        bytes32 descriptionHash = 0x2b3d6e1302ebbdbd512643bb0f99b6134d2df5100c1a96f05862d67c20435ab6;
        governor.createProposal(
            targets,
            values,
            calldatas,
            "This is a test Proposal",
            1000
        );
        vm.roll(block.number + 1);
        uint256 proposalId = governor.hashProposal(
            targets,
            values,
            calldatas,
            descriptionHash
        );
        vote.mint(joe, 200);
        vm.roll(block.number + 1);
        vm.stopPrank();

        vm.startPrank(alice);
        uint256 proposalSnapshot = governor.proposalSnapshot(proposalId);
        uint256 votingPower = governor.getVotes(alice, proposalSnapshot);
        governor.castVote(proposalId, 1);
        vm.roll(block.number + 1);
        (
            uint256 againstVotes,
            uint256 forVotes,
            uint256 abstainVotes
        ) = governor.proposalVotes(proposalId);
        assertEq(againstVotes, 0);
        assertEq(forVotes, votingPower);
        assertEq(abstainVotes, 0);
        vm.stopPrank();

        vm.startPrank(bob);
        governor.castVote(proposalId, 2);
        (
            uint256 againstVotes2,
            uint256 forVotes2,
            uint256 abstainVotes2
        ) = governor.proposalVotes(proposalId);
        vm.roll(block.number + 1);
        assertEq(againstVotes2, 0);
        assertEq(forVotes2, 1000);
        assertEq(abstainVotes2, 500);
        vm.stopPrank();

        vm.startPrank(joe);
        governor.castVote(proposalId, 0);
        (
            uint256 againstVotes3,
            uint256 forVotes3,
            uint256 abstainVotes3
        ) = governor.proposalVotes(proposalId);
        vm.roll(block.number + 1);
        assertEq(againstVotes3, 0);
        assertEq(forVotes3, 1000);
        assertEq(abstainVotes3, 500);
        vm.stopPrank();
    }

    function test_execute() public {
        vm.startPrank(governor.owner());
        vote.mint(alice, 1000);
        vote.mint(bob, 500);
        vm.roll(block.number + 1);
        address[] memory targets = new address[](1);
        targets[0] = address(vote);

        uint256[] memory values = new uint256[](1);
        values[0] = uint256(0);

        bytes memory data = abi.encodeWithSignature(
            "mint(address,uint256)",
            alice,
            9000
        );
        bytes[] memory calldatas = new bytes[](1);

        calldatas[0] = data;
        bytes32 descriptionHash = 0x2b3d6e1302ebbdbd512643bb0f99b6134d2df5100c1a96f05862d67c20435ab6;
        governor.createProposal(
            targets,
            values,
            calldatas,
            "This is a test Proposal",
            1000
        );
        vm.roll(block.number + 1);
        uint256 proposalId = governor.hashProposal(
            targets,
            values,
            calldatas,
            descriptionHash
        );
        vote.mint(joe, 200);
        vm.roll(block.number + 1);
        vm.stopPrank();

        vm.startPrank(alice);
        governor.castVote(proposalId, 1);
        vm.roll(block.number + 1);
        vm.stopPrank();

        vm.startPrank(bob);
        governor.castVote(proposalId, 2);
        vm.roll(block.number + 1);
        vm.stopPrank();

        vm.startPrank(joe);
        governor.castVote(proposalId, 0);
        vm.roll(block.number + 1);
        vm.stopPrank();

        vm.startPrank(governor.owner());
        vote.transferOwnership(address(governor));
        vm.roll(1100);
        uint256 aliceOldBalance = vote.balanceOf(alice);
        governor.execute(targets, values, calldatas, descriptionHash);
        uint256 aliceNewBalance = vote.balanceOf(alice);
        assertEq(aliceNewBalance, aliceOldBalance + 9000);
        vm.stopPrank();
    }
}
