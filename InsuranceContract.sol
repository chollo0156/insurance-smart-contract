// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract InsuranceContract {

    address public insurer;

    constructor() {
        insurer = msg.sender;
    }

    struct Policy {
        uint256 id;
        address holder;
        uint256 premium;
        uint256 coverageAmount;
        uint256 duration;
        bool active;
    }

    struct Claim {
        uint256 policyId;
        uint256 amount;
        string reason;
        bool approved;
        bool paid;
    }

    mapping(uint256 => Policy) public policies;
    mapping(uint256 => Claim) public claims;

    uint256 public policyCount;

    event PolicyIssued(uint256 policyId, address holder);
    event PremiumPaid(uint256 policyId, uint256 amount);
    event ClaimSubmitted(uint256 policyId, uint256 amount);
    event ClaimApproved(uint256 policyId);
    event ClaimPaid(uint256 policyId, uint256 amount);

    function issuePolicy(
        address _holder,
        uint256 _premium,
        uint256 _coverageAmount,
        uint256 _duration
    ) public {

        require(
            msg.sender == insurer,
            "Only insurer can issue policies"
        );

        policyCount++;

        policies[policyCount] = Policy(
            policyCount,
            _holder,
            _premium,
            _coverageAmount,
            _duration,
            true
        );

        emit PolicyIssued(policyCount, _holder);
    }

    function payPremium(uint256 _id) public payable {

        require(
            policies[_id].active,
            "Policy not active"
        );

        require(
            msg.value == policies[_id].premium,
            "Incorrect premium amount"
        );

        emit PremiumPaid(_id, msg.value);
    }

    function submitClaim(
        uint256 _policyId,
        uint256 _amount,
        string memory _reason
    ) public {

        require(
            policies[_policyId].active,
            "Policy not active"
        );

        claims[_policyId] = Claim(
            _policyId,
            _amount,
            _reason,
            false,
            false
        );

        emit ClaimSubmitted(_policyId, _amount);
    }

    function approveClaim(uint256 _policyId) public {

        require(
            msg.sender == insurer,
            "Only insurer can approve claims"
        );

        claims[_policyId].approved = true;

        emit ClaimApproved(_policyId);
    }

    function payClaim(uint256 _policyId) public {

        require(
            claims[_policyId].approved,
            "Claim not approved"
        );

        require(
            !claims[_policyId].paid,
            "Already paid"
        );

        claims[_policyId].paid = true;

        emit ClaimPaid(
            _policyId,
            claims[_policyId].amount
        );
    }
}