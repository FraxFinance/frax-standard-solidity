import { camelCase } from "change-case";
import { AbiItem, Struct, Input } from "./types";

const makeStruct = (func: AbiItem): Struct => {
  return {
    name: firstToUppercase(func.name) + "Return",
    items: func.outputs.map((output) => {
      return {
        name: getOutputName(output),
        type: getOutputType(output),
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

const getOutputName = (output: Input) => {
  return output.name.replace(/^_/, "");
};

const firstToUppercase = (str: string) => {
  return str.charAt(0).toUpperCase() + str.slice(1);
};

export const buildHelper = async (abi, NAME, RETURN_NAME) => {
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
    const argTypeStrings = funcOut.args.map((arg) => arg.type + arg.name);
    const argStrings = funcOut.args.map((arg) => arg.name);
    const name = `_${camelCase(NAME)}`;
    const nameType = `${NAME}`;
    const nameWithType = `${nameType} ${name}`;
    const functionArgs = `${[nameWithType, ...argTypeStrings].join(", ")}`;
    const structItemsString = `${struct.items.map((item) => RETURN_NAME + item.name).join(", ")}`;
    const funcString = `
    function __${func.name}( ${functionArgs} ) internal ${func.stateMutability} returns (${
      struct.name
    } memory ${RETURN_NAME}) {
      ( ${structItemsString} ) = ${func.name}(${argStrings.join(", ")});
    }

    function __${func.name}(I${functionArgs}) internal ${func.stateMutability} returns (${
      struct.name
    } memory ${RETURN_NAME}) {
      ${nameWithType} = ${NAME}(address(${name}));
      return __${func.name}(${argStrings.join(", ")});
    }`;

    return [structString, funcString];
  });

  const outputString = `
  library ${NAME}Helper {
    ${items.map((item) => item[0] + "\n" + item[1]).join("\n    ")}
  }`;
  return outputString;
};
