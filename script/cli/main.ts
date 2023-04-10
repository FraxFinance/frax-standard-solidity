import fs from "fs";
import path from "path";
import { Command } from "commander";
import { buildHelper } from "./build-helper/library";
import { toNamedImports } from "./toNamedImports";

const program = new Command();

program.name("frax");

program
  .command("buildHelper")
  .argument("<abi-path>", "path to abi file")
  .argument("<name>", "name of Library Helper")
  .action(async (abiPath, name) => {
    abiPath = path.resolve(abiPath);
    const abi = JSON.parse(fs.readFileSync(abiPath, "utf8"));
    const NAME = name;
    const RETURN_NAME = "_return";
    // main(abi, NAME, RETURN_NAME).then(str => {
    //   process.stdout.write(str)
    // })
    process.stdout.write(await buildHelper(abi, NAME, RETURN_NAME));
  });

program
  .command("renameImports")
  .argument("<paths...>", "glob path to abi file")
  .action((paths) => {
    toNamedImports(paths);
  });

program.parse();
