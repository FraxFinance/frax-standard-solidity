#!/usr/bin/env node

import { Command } from "commander";
import { buildHelperAction } from "./build-helper/library";
import { buildHoaxHelperAction, hoaxAction } from "./build-hoax-helper/library";
import { toNamedImports } from "./toNamedImports";
import { getAbi, newGetAbi, getFilesFromFraxToml } from "./utils";

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
  .command("hoax")
  .option("-w, --watch", "watch files")
  .argument("[paths...]", "paths to source files")
  .action(async (paths, options) => {
    if (paths.length > 0) {
      await hoaxAction(paths, options.watch);
    } else {
      const defaultPaths = getFilesFromFraxToml();
      await hoaxAction(defaultPaths, options.watch);
    }
  });

program
  .command("renameImports")
  .argument("<paths...>", "glob path to abi file")
  .action((paths) => {
    toNamedImports(paths);
  });

program
  .command("abi")
  .argument("<paths...>", "glob path to abi file")
  .action(async (paths) => {
    const abi = await newGetAbi(paths[0]);
    const abiString = JSON.stringify(abi, null, 2);
    process.stdout.write(abiString);
  });

program.parse();
