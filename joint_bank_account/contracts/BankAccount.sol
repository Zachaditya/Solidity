pragma solidity >=0.4.22 <=0.8.19;

contract BankAccount {
    event Deposit(
        address indexed user,
        uint256 indexed accountId,
        uint256 value,
        uint256 timestamp
    );
    event WithdrawRequested(
        address indexed user,
        uint256 indexed accountId,
        uint256 indexed withdrawId,
        uint256 amount,
        uint256 timestamp
    );

    event AccountCreated(
        address[] owners,
        uint256 indexed id,
        uint256 timestamp
    );

    event Withdraw(address indexed withdrawId, uint256 timestamp);

    struct WithdrawRequest {
        address user;
        uint amount;
        uint approvals;
        mapping(address => bool) ownersApproved;
        bool approved;
    }

    struct Account {
        address[] owners;
        uint balance;
        mapping(uint => WithdrawRequest) withdrawRequests;
    }

    mapping(uint => Account) accounts;
    mapping(address => uint[]) userAccounts;

    uint nextAccountId;
    uint nextWithdrawId;

    modifier accountOwner(uint accountId) {
        bool isOwner;
        for (uint i; i < accounts[accountId].owners.length; i++) {
            if (accounts[accountId].owners[i] == msg.sender) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "You are not the owner");
        _;
    }

    modifier validOwners(address[] calldata owners) {
        require(owners.length + 1 <= 4, "maximum of 4 owners per account");
        for (uint i; i < owners.length; i++) {
            for (uint j = i + 1; j < owners.length; j++) {
                if (owners[i] == owners[j]) {
                    revert("no duplicate owners");
                }
            }
        }

        _;
    }

    modifier sufficientBalance(uint accountId, uint amount) {
        require(accounts[accountId].balance >= amount, "insufficient balance");
        _;
    }

    modifier canApprove(uint accountId, uint withdrawId){
        require(!accounts[accountId].withdrawRequests[withdrawId].approved, "this request is already approved");
        require(accounts[account])
    }

    function deposit(uint accountId) external payable accountOwner(accountId) {
        accounts[accountId].balance += msg.value;
    }

    function createAccount(
        address[] calldata otherowners
    ) external validOwners(otherowners) {
        address[] memory owners = new address[](otherowners.length + 1);
        owners[otherowners.length] = msg.sender;

        uint id = nextAccountId;

        for (uint i; i < owners.length; i++) {
            if (i < owners.length - 1) {
                owners[i] = otherowners[i];
            }
            if (userAccounts[owners[i]].length > 2) {
                revert("max 3 accounts");
            }
            userAccounts[owners[i]].push(id);
        }

        accounts[id].owners = owners;
        nextAccountId++;

        emit AccountCreated(owners, id, block.timestamp);
    }

    function requestWithdrawal(
        uint accountId,
        uint amount
    ) external accountOwner(accountId) sufficientBalance(accountId, amount) {
        uint id = nextWithdrawId;

        WithdrawRequest storage request = accounts[accountId].withdrawRequests[
            id
        ];

        request.user = msg.sender;
        request.amount = amount;
        nextWithdrawId++;

        emit WithdrawRequested(
            msg.sender,
            accountId,
            id,
            amount,
            block.timestamp
        );
    }
    function approveWithdrawal(
        uint accountId,
        uint withdrawId
    ) external accountOwner(accountId) {
        WithdrawRequest storage request = accounts[accountId].withdrawRequests[
            withdrawId
        ];
        request.approvals++;
        request.ownersApproved[msg.sender] = true;

        if (request.approvals == accounts[accountId].owners.length - 1) {
            request.approved = true;
        }
    }

    function withdraw(uint acountId, uint withdrawId) external {}

    function getBalance(uint accountId) public view returns (uint) {}

    function getOwners(uint accountid) public view returns (address[] memory) {}

    function getApprovals(
        uint accountId,
        uint withdrawId
    ) public view returns (uint) {}

    function getAccounts() public view returns (uint[] memory) {}
}
