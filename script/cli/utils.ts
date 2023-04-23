import path from "path";
import fs from "fs";
import toml from "toml";
import { glob } from "glob";
import solc from "solc";

export const getFileContractNames = (fileContents) => {
  const contractNames = [];
  const contractRegex = /contract\s+(\w+)/g;
  let match = contractRegex.exec(fileContents);
  while (match) {
    contractNames.push(match[1]);
    match = contractRegex.exec(fileContents);
  }
  return contractNames;
};

export const getOutFileFromSourcePath = (sourcePath) => {
  const fileName = path.basename(sourcePath);
  const fileContents = fs.readFileSync(sourcePath).toString();
  const contractNames = getFileContractNames(fileContents);
  const outDirectory = getOutDirectory();
  const abiFilePaths = contractNames.map((contractName) => path.join(outDirectory, fileName, `${contractName}.json`));
  return abiFilePaths;
};

export const getAbiWithName = async (name) => {
  const outDirectory = getOutDirectory();
  const abiFilePaths = await glob(`${outDirectory}/**/${name}.json`);
  if (abiFilePaths.length === 0) {
    throw new Error(`No abi file found for ${name}`);
  } else if (abiFilePaths.length > 1) {
    throw new Error(`Multiple abi files found for ${name}`);
  }
  const abi = getAbiFromFile(abiFilePaths[0]);
  return abi;
};

export const getAbiFromFile = (abiPath) => {
  let abi = JSON.parse(fs.readFileSync(abiPath).toString());
  if (Object.keys(abi).includes("abi")) {
    abi = abi.abi;
  }
  return abi;
};

export const getAbiFromPath = (abiPath) => {
  const abi = getAbiFromFile(abiPath);
  return abi;
};

export const getAbi = (abiPath) => {
  if (!abiPath.includes("/")) {
    const outDirectory = getOutDirectory();
    abiPath = path.join(outDirectory, abiPath + ".sol", `${abiPath}.json`);
  } else {
    abiPath = path.resolve(abiPath);
  }

  let abi = JSON.parse(fs.readFileSync(abiPath).toString());
  if (Object.keys(abi).includes("abi")) {
    abi = abi.abi;
  }
  return abi;
};

export const getOutDirectory = () => {
  const foundryTomlPath = path.resolve("foundry.toml");
  const foundryConfigString = fs.readFileSync(foundryTomlPath, "utf-8").toString();
  const foundryConfig = toml.parse(foundryConfigString);
  const outValue = foundryConfig.profile.default.out;
  const outDirectory = path.resolve(outValue);
  return outDirectory;
};

export const getHelperDirectory = () => {
  const fraxTomlPath = path.resolve("frax.toml");
  const fraxConfigString = fs.readFileSync(fraxTomlPath, "utf-8").toString();
  const fraxConfig = toml.parse(fraxConfigString);
  const helperValue = fraxConfig.helper_dir;
  const helperDirectory = path.resolve(helperValue);
  return helperDirectory;
};

export const isDynamicType = (internalType) => {
  if (internalType.includes("[")) {
    return true;
  }

  if (internalType === "bytes") {
    return true;
  }

  if (internalType.includes("struct")) {
    return true;
  }

  if (internalType.includes("contract")) {
    return true;
  }

  return false;
};

export const newGetAbi = async (filePath) => {
  const fileContents = fs.readFileSync(filePath).toString();
  console.log("file: utils.ts:108 ~ newGetAbi ~ fileContents:", fileContents);
  const input = {
    language: "Solidity",
    sources: {
      [path.basename(filePath)]: {
        content: fileContents,
      },
    },
    settings: {
      outputSelection: {
        "*": {
          "*": ["abi"],
        },
      },
    },
  };

  const output = solc.compile(JSON.stringify(input), { import: true });
  const parsed = JSON.parse(output);
  return parsed;
};
