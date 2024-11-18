const provider = new ethers.providers.Web3Provider(window.ethereum);
window.onerror = function (message, source, lineno, colno, error) {
  console.error("Global Error Caught:");
  console.error("Message:", message);
  console.error("Source:", source);
  console.error("Line:", lineno, "Column:", colno);
  console.error("Error object:", error);
};

const abi = [
  "event AccountCreated(address[],uint256 indexed,uint256)",
  "event Deposit(address indexed,uint256 indexed,uint256,uint256)",
  "event Withdraw(uint256 indexed,uint256)",
  "event WithdrawRequested(address indexed,uint256 indexed,uint256 indexed,uint256,uint256)",
  "function approveWithdrawal(uint256,uint256)",
  "function createAccount(address[])",
  "function deposit(uint256) payable",
  "function getAccounts() view returns (uint256[])",
  "function getApprovals(uint256,uint256) view returns (uint256)",
  "function getBalance(uint256) view returns (uint256)",
  "function getOwners(uint256) view returns (address[])",
  "function requestWithdrawal(uint256,uint256)",
  "function withdraw(uint256,uint256)",
];

const address = "0x0DCd1Bf9A1b36cE34237eEaFef220932846BCD82";
let contract = null;

async function createAccount() {
  await getAccess();
  const owners = document
    .getElementById("owners")
    .value.split(",")
    .filter((n) => n);
  console.log(owners);

  await contract.createAccount(owners).then(() => alert("Success"));
}

async function viewAccounts() {
  await getAccess();
  const result = await contract.getAccounts();
  console.log(result);
  document.getElementById("accounts").innerHTML = result;
}

async function getAccess() {
  if (contract) return;
  await provider.send("eth_requestAccounts", []);
  const signer = provider.getSigner();
  contract = new ethers.Contract(address, abi, signer);

  const eventLog = document.getElementById("events");
  contract.on("AccountCreated", (owners, id, event) => {
    eventLog.append(`Account Created: ID = ${id}, Owners = ${owners}`);
  });
}
