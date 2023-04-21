import { camelCase } from "change-case";
import { AbiItem, Struct, Input } from "../types";

const makeStruct = (func: AbiItem): Struct => {
  return {
    name: firstToUppercase(func.name) + "Return",
    items: func.outputs.map((output, index) => {
      return {
        name: getOutputName(output, index),
        type: getOutputType(output).replace(" memory", ""),
      };
    }),
  };
};

const getOutputType = (output: Input) => {
  const isDynamic = output.internalType.match(/(struct|^bytes$|\[\])/);
  if (isDynamic) {
    const words = output.internalType.split(" ");
    return words[words.length - 1] + " memory";
  } else {
    return output.internalType;
  }
};

const getOutputName = (output: Input, index) => {
  const cleanedName = output.name.replace(/^_/, "");
  const name = cleanedName ? cleanedName : "returnVal" + index;
  return name;
};

const getInputName = (input: Input, index) => {
  const cleanedName = input.name.replace(/^_/, "");
  const name = cleanedName ? cleanedName : "_arg" + index;
  return name;
};

const firstToUppercase = (str: string) => {
  return str.charAt(0).toUpperCase() + str.slice(1);
};

export const buildHelperAction = async (abi, name, options) => {
  const NAME = name;
  const INAME = options?.i ?? null;
  const RETURN_NAME = "_return";
  process.stdout.write(await buildHelper(abi, NAME, INAME, RETURN_NAME));
};

export const buildHelper = async (abi, NAME, INAME, RETURN_NAME) => {
  const funcs = (abi as AbiItem[]).filter((item) => item.type === "function" && item?.outputs?.length > 1);

  const items = funcs.map((func) => {
    const struct = makeStruct(func);
    const structString = `
    struct ${struct.name} {
    ${struct.items.map((item) => `  ${item.type} ${item.name};`).join("\n    ")}
    }`;
    const funcOut = {
      name: func.name,
      args: func.inputs.map((input) => {
        return {
          name: input.name,
          type: input.internalType,
        };
      }),
    };
    const argTypeStrings = funcOut.args.map((arg, index) => arg.type + " " + (arg.name ? arg.name : "arg" + index));
    const argStrings = funcOut.args.map((arg, index) => (arg.name ? arg.name : "arg" + index));
    const name = `_${camelCase(NAME)}`;
    const nameType = `${NAME}`;
    const nameWithType = `${nameType} ${name}`;
    const functionArgs = `${[nameWithType, ...argTypeStrings].join(", ")}`;
    const iFunctionArgs = `${[nameWithType, ...argTypeStrings].join(", ")}`.replace(NAME, INAME);
    const structItemsString = `${struct.items.map((item) => RETURN_NAME + "." + item.name).join(", ")}`;
    const funcString = `
    function __${func.name}( ${functionArgs} ) internal ${func.stateMutability} returns (${
      struct.name
    } memory ${RETURN_NAME}) {
      ( ${structItemsString} ) = ${name}.${func.name}(${argStrings.join(", ")});
    }`;

    const interfaceString = `
    function __${func.name}(${iFunctionArgs}) internal ${func.stateMutability} returns (${
      struct.name
    } memory ${RETURN_NAME}) {
      ${nameWithType} = ${NAME}(address(${name}));
      return __${func.name}(${[name, ...argStrings].filter(Boolean).join(", ")});
    }`;

    return [structString, funcString, interfaceString];
  });

  const outputString = `
  // SPDX-License-Identifier: ISC
  pragma solidity ^0.8.19;

  import "src/${NAME}.sol";

  library ${NAME}StructHelper {
    ${items.map((item) => item[0] + "\n" + item[1] + "\n" + (INAME ? item[2] : "")).join("\n    ")}
  }`;
  return outputString;
};
