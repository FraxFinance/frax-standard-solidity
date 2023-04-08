import * as fs from "fs/promises";
import * as path from "path";

export async function renameFile(filePath) {
  const fileContents = (await fs.readFile(path.resolve(filePath), "utf8")).toString();
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

export async function toNamedImports(filePaths) {
  filePaths.forEach(renameFile);
}