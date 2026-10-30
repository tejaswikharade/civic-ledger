// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title CivicLedger
/// @notice A minimal, one-address-one-vote ledger for civic proposals.
/// @dev Execution deliberately records an approved outcome only. Integrations can listen to events.
contract CivicLedger {
    uint64 public constant MIN_VOTING_PERIOD = 1 days;
    uint64 public constant MAX_VOTING_PERIOD = 30 days;

    struct Proposal {
        address proposer;
        string title;
        string description;
        uint64 startsAt;
        uint64 endsAt;
        uint128 votesFor;
        uint128 votesAgainst;
        bool executed;
    }

    error EmptyTitle();
    error InvalidVotingPeriod();
    error UnknownProposal();
    error VotingNotOpen();
    error AlreadyVoted();
    error VotingStillOpen();
    error ProposalDidNotPass();
    error AlreadyExecuted();

    event ProposalCreated(
        uint256 indexed proposalId,
        address indexed proposer,
        string title,
        uint64 startsAt,
        uint64 endsAt
    );
    event VoteCast(uint256 indexed proposalId, address indexed voter, bool support);
    event ProposalExecuted(uint256 indexed proposalId, uint128 votesFor, uint128 votesAgainst);

    Proposal[] private _proposals;
    mapping(uint256 proposalId => mapping(address voter => bool)) public hasVoted;

    function propose(
        string calldata title,
        string calldata description,
        uint64 votingPeriod
    ) external returns (uint256 proposalId) {
        if (bytes(title).length == 0) revert EmptyTitle();
        if (votingPeriod < MIN_VOTING_PERIOD || votingPeriod > MAX_VOTING_PERIOD) {
            revert InvalidVotingPeriod();
        }

        uint64 startsAt = uint64(block.timestamp);
        uint64 endsAt = startsAt + votingPeriod;
        proposalId = _proposals.length;
        _proposals.push(
            Proposal({
                proposer: msg.sender,
                title: title,
                description: description,
                startsAt: startsAt,
                endsAt: endsAt,
                votesFor: 0,
                votesAgainst: 0,
                executed: false
            })
        );

        emit ProposalCreated(proposalId, msg.sender, title, startsAt, endsAt);
    }

    function vote(uint256 proposalId, bool support) external {
        Proposal storage proposal = _proposalAt(proposalId);
        if (block.timestamp < proposal.startsAt || block.timestamp >= proposal.endsAt) {
            revert VotingNotOpen();
        }
        if (hasVoted[proposalId][msg.sender]) revert AlreadyVoted();

        hasVoted[proposalId][msg.sender] = true;
        if (support) proposal.votesFor += 1;
        else proposal.votesAgainst += 1;

        emit VoteCast(proposalId, msg.sender, support);
    }

    /// @notice Finalizes a successful proposal after voting closes.
    /// @dev Any address may finalize; approval requires more for-votes than against-votes.
    function execute(uint256 proposalId) external {
        Proposal storage proposal = _proposalAt(proposalId);
        if (block.timestamp < proposal.endsAt) revert VotingStillOpen();
        if (proposal.executed) revert AlreadyExecuted();
        if (proposal.votesFor <= proposal.votesAgainst) revert ProposalDidNotPass();

        proposal.executed = true;
        emit ProposalExecuted(proposalId, proposal.votesFor, proposal.votesAgainst);
    }

    function proposalCount() external view returns (uint256) {
        return _proposals.length;
    }

    function getProposal(uint256 proposalId) external view returns (Proposal memory) {
        return _proposalAt(proposalId);
    }

    function proposalStatus(uint256 proposalId) external view returns (string memory) {
        Proposal storage proposal = _proposalAt(proposalId);
        if (proposal.executed) return "Executed";
        if (block.timestamp < proposal.startsAt) return "Scheduled";
        if (block.timestamp < proposal.endsAt) return "Open";
        if (proposal.votesFor > proposal.votesAgainst) return "Ready to execute";
        return "Rejected";
    }

    function _proposalAt(uint256 proposalId) private view returns (Proposal storage) {
        if (proposalId >= _proposals.length) revert UnknownProposal();
        return _proposals[proposalId];
    }
}
