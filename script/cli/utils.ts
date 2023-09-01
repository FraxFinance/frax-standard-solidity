import path from "path";
import fs from "fs";
import toml from "toml";
import { glob } from "glob";
import { execSync } from "child_process";

export const getFilesFromFraxToml = () => {
  const fraxConfig = parseFraxToml();
  const files = fraxConfig.files;
  return files;
};

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

const parseFoundryToml = () => {
  const foundryTomlPath = path.resolve("foundry.toml");
  const foundryConfigString = fs.readFileSync(foundryTomlPath, "utf-8").toString();
  const foundryConfig = toml.parse(foundryConfigString);
  return foundryConfig;
};

export const getOutDirectory = () => {
  const foundryConfig = parseFoundryToml();
  const outValue = foundryConfig.profile.default.out;
  const outDirectory = path.resolve(outValue);
  return outDirectory;
};

const parseFraxToml = () => {
  const fraxTomlPath = path.resolve("frax.toml");
  const fraxConfigString = fs.readFileSync(fraxTomlPath, "utf-8").toString();
  const fraxConfig = toml.parse(fraxConfigString);
  return fraxConfig;
};

export const getHelperDirectory = () => {
  const fraxConfig = parseFraxToml();
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

  if (internalType.includes("string")) {
    return true;
  }

  return false;
};

export const newGetAbi = async (filePath) => {
  const contractBasename = path.basename(filePath);
  const input = {
    language: "Solidity",
    sources: {
      [filePath]: {
        urls: [filePath],
      },
    },
    settings: {
      remappings: remappingsToArray(),
      metadata: {
        bytecodeHash: "none",
        appendCBOR: true,
      },
      outputSelection: {
        [filePath]: {
          "*": ["abi"],
        },
      },
      evmVersion: "london",
      libraries: {},
    },
  };
  const fileName = `${Date.now().toString()}${contractBasename}${Math.random()}.json`;
  fs.writeFileSync(fileName, JSON.stringify(input));
  const command = `solc --pretty-json ${getIncludeSources()
    .map((item) => "--include-path " + item)
    .join(" ")} --base-path . --standard-json ${fileName}`;
  const output = execSync(command).toString();
  fs.unlink(fileName, () => {});
  const parsed = JSON.parse(output);
  delete parsed.sources;
  return parsed.contracts[filePath];
};

const remappingsToArray = () => {
  const contents = fs.readFileSync("remappings.txt").toString();
  const lines = contents.split("\n").filter(Boolean);
  return lines;
};

const getIncludeSources = () => {
  const foundryConfig = parseFoundryToml();
  const includeSources = foundryConfig.profile.default.libs;
  return includeSources;
};

function importCallbackGenerator(includeSources) {
  return function readFileCallback(sourcePath) {
    const prefixes = includeSources;
    for (const prefix of prefixes) {
      const prefixedSourcePath = (prefix ? prefix + "/" : "") + sourcePath;

      if (fs.existsSync(prefixedSourcePath)) {
        try {
          return { contents: fs.readFileSync(prefixedSourcePath).toString("utf8") };
        } catch (e) {
          return { error: "Error reading " + prefixedSourcePath + ": " + e };
        }
      }
    }
    return { error: "File not found inside the base path or any of the include paths." };
  };
}
