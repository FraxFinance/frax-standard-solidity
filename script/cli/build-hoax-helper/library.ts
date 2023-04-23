import { camelCase } from "change-case";
import { AbiItem, Struct, Input } from "../types";
import { isDynamicType, getFileContractNames, getOutDirectory, getAbiFromFile, getHelperDirectory } from "../utils";
import fs from "fs";
import path from "path";
import { glob } from "glob";

export const hoaxAction = (paths) => {
  paths.forEach(processOnePath);
};

const processOnePath = async (filePath) => {
  const outDirectory = getOutDirectory();
  const folderName = path.basename(filePath);
  const filePaths = await glob(`${outDirectory}/${folderName}/**/*.json`);

  const abiWithContractName = filePaths.map((filePath) => {
    return {
      contractName: path.basename(filePath, ".json"),
      abi: getAbiFromFile(filePath),
    };
  });

  abiWithContractName.forEach(async (item) => {
    const hoaxFile = await buildHoaxHelper(item.abi, item.contractName, filePath);
    const helperDirectory = getHelperDirectory();
    fs.writeFileSync(path.join(helperDirectory, `${item.contractName}HoaxHelper.sol`), hoaxFile);
  });
};

export const buildHoaxHelperAction = async (abi, name) => {
  const NAME = name;
  process.stdout.write(await buildHoaxHelper(abi, NAME));
};

const formatType = (internalType, contractName) => {
  if (isDynamicType(internalType)) {
    if (internalType.includes("struct")) {
      return internalType.replace("struct ", contractName + ".") + " memory";
    } else if (internalType.includes("contract")) {
      return internalType.replace("contract ", "");
    } else return internalType + " memory";
  } else {
    return internalType;
  }
};

export const buildHoaxHelper = async (abi, NAME, filePath = null) => {
  const funcs = (abi as AbiItem[]).filter((item) => item.type === "function");

  const items = funcs.map((func) => {
    const funcOut = {
      name: func.name,
      args: func.inputs.map((input) => {
        return {
          name: input.name,
          type: formatType(input.internalType, NAME),
        };
      }),
      returns: func.outputs.map((output) => {
        return {
          name: output.name,
          type: formatType(output.internalType, NAME),
        };
      }),
    };
    const argTypeStrings = funcOut.args.map((arg, index) => arg.type + " " + (arg.name ? arg.name : "arg" + index));
    const returnTypeStrings = funcOut.returns.map(
      (output, index) => output.type + " " + (output.name ? output.name : "return" + index)
    );
    const argStrings = funcOut.args.map((arg, index) => (arg.name ? arg.name : "arg" + index));
    const returnStrings = funcOut.returns.map((arg, index) => (arg.name ? arg.name : "return" + index));
    const name = `_${camelCase(NAME)}`;
    const nameType = `${NAME}`;
    const nameWithType = `${nameType} ${name}`;
    const functionArgs = `${[nameWithType, ...argTypeStrings].join(", ")}`;
    const cleanedStateMutability = func.stateMutability
      .replace("payable", "")
      .replace("view", "")
      .replace("non", "")
      .replace("pure", "");
    const isPayable = func.stateMutability.includes("payable") && !func.stateMutability.includes("nonpayable");
    const returnsFuncDef = `${returnTypeStrings.length ? "returns (" + returnTypeStrings + ")" : ""}`;
    const returnArgsAssign = `${returnTypeStrings.length ? "(" + returnStrings + ") = " : ""}`;

    const funcString = `
    function __${func.name}_As( ${[
      nameWithType,
      "address _impersonator",
      isPayable ? "uint256 _value" : null,
      ...argTypeStrings,
    ]
      .filter(Boolean)
      .join(", ")} ) internal ${cleanedStateMutability} ${returnsFuncDef} {
      vm.startPrank(_impersonator);
      ${returnArgsAssign} ${name}.${func.name}${isPayable ? "{ value: _value}" : ""}(${argStrings});
      vm.stopPrank();
    }`;

    return [funcString];
  });

  const outputString = `
  // SPDX-License-Identifier: ISC
  pragma solidity ^0.8.19;
  
  // **NOTE** This file is auto-generated do not edit it directly.
  // Run \`frax hoax ${filePath ? "hoax " + filePath : "buildHoaxHelper " + NAME + " " + NAME}\` to re-generate it.


  import { Vm } from "forge-std/Test.sol";
  import ${filePath ? '"' + filePath + '"' : '"src/contracts/' + NAME + '.sol"'};

  library ${NAME}HoaxHelper {

    address internal constant VM_ADDRESS = address(uint160(uint256(keccak256("hevm cheat code"))));
    Vm internal constant vm = Vm(VM_ADDRESS);

    ${items.map((item) => item[0]).join("\n    ")}
  }`;
  return outputString;
};
