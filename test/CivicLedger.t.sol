// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {CivicLedger} from "../src/CivicLedger.sol";

interface Vm {
    function warp(uint256 newTimestamp) external;
}

contract Voter {
    function vote(CivicLedger ledger, uint256 proposalId, bool support) external {
        ledger.vote(proposalId, support);
    }
}

contract CivicLedgerTest {
    Vm private constant vm = Vm(address(uint160(uint256(keccak256("hevm cheat code")))));
    CivicLedger private ledger;
    Voter private alice;
    Voter private bob;

    function setUp() public {
        ledger = new CivicLedger();
        alice = new Voter();
        bob = new Voter();
    }

    function testCreatesAnOpenProposal() public {
        uint256 id = ledger.propose("Plant street trees", "Fund shade along Market Street.", 3 days);
        CivicLedger.Proposal memory proposal = ledger.getProposal(id);

        _assertEq(ledger.proposalCount(), 1, "proposal count");
        _assertEq(proposal.votesFor, 0, "yes votes");
        _assertEq(keccak256(bytes(ledger.proposalStatus(id))), keccak256("Open"), "status");
    }

    function testOneAddressCanVoteOnlyOnce() public {
        uint256 id = ledger.propose("Repair the library roof", "Protect the reading room.", 1 days);
        alice.vote(ledger, id, true);
        _assertEq(ledger.hasVoted(id, address(alice)), true, "vote was recorded");

        try alice.vote(ledger, id, false) {
            revert("expected duplicate vote to revert");
        } catch {}
    }

    function testFinalizesOnlyAWinningProposalAfterVotingEnds() public {
        uint256 id = ledger.propose("Add protected bike lanes", "Build a safer north-south route.", 1 days);
        alice.vote(ledger, id, true);
        bob.vote(ledger, id, true);

        try ledger.execute(id) {
            revert("expected early execution to revert");
        } catch {}

        vm.warp(block.timestamp + 1 days);
        ledger.execute(id);
        CivicLedger.Proposal memory proposal = ledger.getProposal(id);
        _assertEq(proposal.executed, true, "proposal executed");
        _assertEq(keccak256(bytes(ledger.proposalStatus(id))), keccak256("Executed"), "status");
    }

    function testRejectsVotesAfterWindowCloses() public {
        uint256 id = ledger.propose("Fresh proposal", "A short window.", 1 days);
        vm.warp(block.timestamp + 1 days);

        try alice.vote(ledger, id, true) {
            revert("expected late vote to revert");
        } catch {}
    }

    function _assertEq(uint256 actual, uint256 expected, string memory message) private pure {
        require(actual == expected, message);
    }

    function _assertEq(bool actual, bool expected, string memory message) private pure {
        require(actual == expected, message);
    }

    function _assertEq(bytes32 actual, bytes32 expected, string memory message) private pure {
        require(actual == expected, message);
    }
}
