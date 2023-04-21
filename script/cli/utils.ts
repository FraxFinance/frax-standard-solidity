import path from "path";
import fs from "fs";
import toml from "toml";

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

export const isDynamicType = (internalType) => {
  if (internalType.includes("[]")) {
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
