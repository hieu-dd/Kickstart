pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(uint256 minimum) public {
        address deploy = new Campaign(minimum, msg.sender);
        deployedCampaigns.push(deploy);
    }

    function getCampaigns() public view returns (address[]){
        return deployedCampaigns;
    }
}


contract Campaign {
    struct Request {
        string description;
        uint256 value;
        address recipient;
        bool complete;
        uint256 approvalCount;
        mapping(address => bool) approvals;
    }

    Request[] public requests;
    address public manager;
    uint256 public minimumContribute;
    mapping(address => bool) approvers;
    uint256 public approversCount;

    function Campaign(uint256 minimumValue, address creator) public {
        manager = creator;
        minimumContribute = minimumValue;
    }

    modifier retricted() {
        require(msg.sender == manager);
        _;
    }

    modifier requireApprover() {
        require(approvers[msg.sender]);
        _;
    }

    function contribute() public payable {
        require(msg.value >= minimumContribute);
        approvers[msg.sender] = true;
    }

    function createRequest(
        string description,
        uint256 value,
        address recipient
    ) public retricted {
        Request memory newRequest = Request({
        description : description,
        value : value,
        recipient : recipient,
        complete : false,
        approvalCount : 0
        });
        requests.push(newRequest);
    }

    function approveRequest(uint256 requestIndex) public requireApprover {
        require(!requests[requestIndex].approvals[msg.sender]);
        requests[requestIndex].approvals[msg.sender] = true;
        requests[requestIndex].approvalCount++;
    }

    function finalizeRequest(uint256 index) public retricted {
        Request storage request = requests[index];
        require(!request.complete);
        require(request.approvalCount > approversCount / 2);
        request.recipient.transfer(request.value);
        request.complete = true;
    }

    function getSummary() public view returns (
        uint,
        uint,
        uint,
        uint,
        address
    ){
        return (
        minimumContribute,
        this.balance,
        requests.length,
        approversCount,
        manager
        );
    }
}
