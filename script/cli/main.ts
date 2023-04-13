#!/usr/bin/env node

import { Command } from "commander";
import { buildHelperAction } from "./build-helper/library";
import { toNamedImports } from "./toNamedImports";

const program = new Command();

program.name("frax");

program
  .command("buildHelper")
  .argument("<abi-path>", "path to abi file or name of contract")
  .argument("<name>", "name of Library Helper")
  .option("-i <type>", "--interface <type>", "name of interface")
  .action(async (abiPath, name, options) => {
    await buildHelperAction(abiPath, name, options);
  });

program
  .command("renameImports")
  .argument("<paths...>", "glob path to abi file")
  .action((paths) => {
    toNamedImports(paths);
  });

program.parse();
