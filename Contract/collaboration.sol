// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract SchoolCollaboration {
    struct Proposal {
        uint256 id;
        address proposer;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool executed;
    }

    struct Resource {
        string name;
        string resourceURI;
        address owner;
    }

    Proposal[] public proposals;
    Resource[] public resources;
    mapping(address => bool) public isSchool;
    mapping(uint256 => mapping(address => bool)) public votes;

    uint256 public proposalCount;
    uint256 public resourceCount;

    modifier onlySchool() {
        require(isSchool[msg.sender], "Only registered schools can call this function");
        _;
    }

    constructor() {
        isSchool[0x40E2F8aCc07e4c04952be32B257ef61bbc67109B] = true;
        isSchool[0xcb7e9793966CB9212dEF3292c02ae471b1492BDC] = true;
    }

    function proposeCollaboration(string memory _description) public onlySchool {
        proposals.push(Proposal({
            id: proposalCount,
            proposer: msg.sender,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            executed: false
        }));
        proposalCount++;
    }

    function voteOnProposal(uint256 _proposalId, bool _support) public onlySchool {
        require(_proposalId < proposalCount, "Proposal does not exist");
        require(!votes[_proposalId][msg.sender], "School has already voted on this proposal");

        Proposal storage proposal = proposals[_proposalId];

        if (_support) {
            proposal.votesFor++;
        } else {
            proposal.votesAgainst++;
        }

        votes[_proposalId][msg.sender] = true;
    }

    function executeProposal(uint256 _proposalId) public onlySchool {
        require(_proposalId < proposalCount, "Proposal does not exist");
        Proposal storage proposal = proposals[_proposalId];
        require(!proposal.executed, "Proposal has already been executed");

        if (proposal.votesFor > proposal.votesAgainst) {
            proposal.executed = true;
        }
    }

    function shareResource(string memory _name, string memory _resourceURI) public onlySchool {
        resources.push(Resource({
            name: _name,
            resourceURI: _resourceURI,
            owner: msg.sender
        }));
        resourceCount++;
    }

    function getResource(uint256 _resourceId) public view returns (string memory, string memory, address) {
        require(_resourceId < resourceCount, "Resource does not exist");

        Resource storage resource = resources[_resourceId];
        return (resource.name, resource.resourceURI, resource.owner);
    }
}
