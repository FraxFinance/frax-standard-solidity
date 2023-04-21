#!/usr/bin/env node

import { Command } from "commander";
import { buildHelperAction } from "./build-helper/library";
import { buildHoaxHelperAction } from "./build-hoax-helper/library";
import { toNamedImports } from "./toNamedImports";
import { getAbi } from "./utils";

const program = new Command();

program.name("frax");

program
  .command("buildStructHelper")
  .argument("<abi-path>", "path to abi file or name of contract")
  .argument("<name>", "name of Library Helper")
  .option("-i <type>", "--interface <type>", "name of interface")
  .action(async (abiPath, name, options) => {
    const abi = getAbi(abiPath);
    await buildHelperAction(abi, name, options);
  });

program
  .command("buildHoaxHelper")
  .argument("<abi-path>", "path to abi file or name of contract")
  .argument("<name>", "name of Library Helper")
  .action(async (abiPath, name, options) => {
    const abi = getAbi(abiPath);
    await buildHoaxHelperAction(abi, name);
  });

program
  .command("renameImports")
  .argument("<paths...>", "glob path to abi file")
  .action((paths) => {
    toNamedImports(paths);
  });

program.parse();
