import { format } from "date-fns";
import * as fs from "fs-extra";
import path from "path";

const DEPLOYMENTS_PATH = path.resolve("deployments");
const METADATA_PATH = path.resolve("out");

const chainToNetwork = {
  1: "mainnet",
};

const main = async () => {
  const args = process.argv.slice(2);
  const chainId = args[0];
  const contractName = args[1];
  const contractAddress = args[2];
  const constructorArguments = args[3];

  if (!fs.existsSync(DEPLOYMENTS_PATH)) fs.mkdirSync(DEPLOYMENTS_PATH);

  const networkName = chainToNetwork[chainId];
  const networkDirPath = path.resolve(DEPLOYMENTS_PATH, networkName);
  if (!fs.existsSync(networkDirPath)) {
    fs.mkdirSync(networkDirPath);
    const chainIdFilePath = path.resolve(networkDirPath, ".chainId");
    fs.writeFileSync(chainIdFilePath, chainId.toString());
  }

  const metadataPath = path.resolve(METADATA_PATH, contractName + ".sol", contractName + ".json");
  const metadata = JSON.parse(fs.readFileSync(metadataPath, "utf8"));
  const outputData = {
    abi: metadata.abi,
    bytecode: metadata.bytecode,
    deployedBytecode: metadata.deployedBytecode,
    metadata: metadata.metadata,
    address: contractAddress,
    constructorArgs: constructorArguments,
  };
  const outputString = JSON.stringify(outputData, null, 2);
  const latestFilePath = path.resolve(networkDirPath, contractName + ".json");
  void (await Promise.all([
    fs.promises.writeFile(latestFilePath, outputString),
    (() => {
      const newDeploymentPath = path.resolve(networkDirPath, format(Date.now(), "yyyyMMdd_HH.mm.ss"));
      const thisDeploymentFilePath = path.resolve(newDeploymentPath, contractName + ".json");
      if (!["hardhat", "localhost"].includes(networkName)) {
        if (!fs.existsSync(newDeploymentPath)) fs.mkdirSync(newDeploymentPath);
        return fs.promises.writeFile(thisDeploymentFilePath, outputString);
      }
    })(),
  ]));
};
void main();
