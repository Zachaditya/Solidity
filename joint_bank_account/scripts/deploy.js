const hre = require("hardhat");
const fs = require("fs/promises");

async function main() {
  // Fetch the Contract Factory
  const BankAccount = await hre.ethers.getContractFactory("BankAccount");

  // Deploy the contract
  const bankAccount = await BankAccount.deploy();

  // Wait for the deployment to be mined
  const deployedContract = await bankAccount.waitForDeployment();
  console.log("Deployed Contract Address:", deployedContract.target);

  // Write deployment info
  await writeDeploymentInfo(deployedContract);
}
async function writeDeploymentInfo(contract) {
  console.log("Deployed Contract Object:", contract);

  const data = {
    contract: {
      address: contract.target, // Deployed contract address
      signerAddress: contract.runner?.address, // Use optional chaining in case it's undefined
      abi: contract.interface.format("json"), // ABI in JSON format
    },
  };

  const content = JSON.stringify(data, null, 2);
  await fs.writeFile("deployment.json", content, { encoding: "utf-8" });
  console.log("Deployment info written to deployment.json");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
