import { ethers, network } from "hardhat";
import verify from "../utils/verify"

async function deployContract() {
  const DochainFactory = await ethers.getContractFactory("Dochain");
  console.log("Deploying contract . . . ")
  let URI = ""
  
  const args : any[] = [
    URI
  ]
  const Dochain = await DochainFactory.deploy(URI)
  await Dochain.deployed()

  if (network.config.chainId === 137 && process.env.ETHERSCAN_API_KEY) {
    await Dochain.deployTransaction.wait(3)
    await verify(Dochain.address, args)
  }

  console.log(`Dochain is deployed to: ${Dochain.address}`)
}


deployContract()
.then(()=> process.exit(0))
.catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
