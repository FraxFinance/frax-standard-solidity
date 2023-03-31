import * as fs from "fs/promises";
import * as path from "path";

async function renameSolidity(filePath) {
  const fileContents = (await fs.readFile(filePath, "utf8")).toString();
  const importStatements =
    (fileContents.match(/import\s+".*;/g) as string[])?.filter((item) => {
      return !item.includes("forge-std") && !item.includes("frax-std");
    }) ?? [];
  const entries = importStatements.map((statement) => {
    const name = statement.match(/\/([a-zA-Z0-9_]+)\./)?.[1] as string;
    const path = statement.match(/".*?";/)?.[0] as string;
    const replace = `import { ${name} } from ${path}`;
    return { original: statement, name, path, replace };
  });
  const newFileContents = entries.reduce((acc, entry) => {
    return acc.replace(entry.original, entry.replace);
  }, fileContents);
  fs.writeFile(filePath, newFileContents, "utf8");
}

const args = process.argv.slice(2);
args.forEach(renameSolidity);
