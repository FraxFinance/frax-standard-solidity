import * as fs from "fs/promises";
import * as path from "path";

async function renameSolidity(filePath) {
  const fileExtension = path.basename(filePath).match(/\..*/)?.[0] as string;
  const fileName = path.basename(filePath).replace(fileExtension, "");
  // console.log("file: rename.ts:6 ~ renameSolidity ~ fileName:", fileName);
  // console.log("file: rename.ts:8 ~ renameSolidity ~ fileExtension:", fileExtension);
  const fileContents = (await fs.readFile(filePath, "utf8")).toString();
  const replace = `contract Test${fileName.replace("Test", "")}`;
  const find = fileContents.match(/contract [a-zA-Z0-9_]+/)?.[0] as string;
  // console.log("file: rename.ts:12 ~ renameSolidity ~ replace:", replace);
  // console.log("file: rename.ts:12 ~ renameSolidity ~ find:", find);
  const newFileContents = fileContents.replace(find, replace);
  await fs.writeFile(filePath, newFileContents, "utf8");
  // console.log("file: rename.ts:12 ~ renameSolidity ~ replace:", replace);
}

const args = process.argv.slice(2);
args.forEach(renameSolidity);
