// This is a crude script to format the binding.gyp file as if it were JSON5.
// As hash-comments are incompatible with JSON, it converts (simple* cases of)
// them to slash-comments, then runs the formatting, then restores them.
//
// * "Simple" cases are one or more hashes preceded only by whitespace.
//   Of course other cases exist, but this is all I can be bothered to support.
import fs from 'node:fs/promises';
import path from 'node:path';
import prettier from 'prettier';

const workspacePath = path.dirname(import.meta.dirname);
const bindingGypPath = path.join(workspacePath, 'binding.gyp');
const prettierConfig = await prettier.resolveConfig(workspacePath);
const bindingGypContents = await fs.readFile(bindingGypPath, 'utf8');

// Replace simple cases of hash-comments with slash-comments.
const recommented = bindingGypContents.split('\n').map(line => {
  const execArray = /^(\s*)(#+)(.*)/.exec(line);
  if (!execArray) {
    return line;
  }
  const [, whitespace, leadingHashes, suffix] = execArray;

  return `${whitespace}${leadingHashes.replace(/#/g, '//')}${suffix}`;
});

// Format as JSON5.
const formatted = await prettier.format(recommented.join('\n'), {
  ...prettierConfig,
  quoteProps: 'preserve',
  parser: 'json5',
});

// Restore slash-comments back to hash-comments.
const finalised = formatted.split('\n').map(line => {
  const execArray = /^(\s*)((?:\/\/)+)(.*)/.exec(line);
  if (!execArray) {
    return line;
  }
  const [, whitespace, leadingHashes, suffix] = execArray;

  return `${whitespace}${leadingHashes.replace(/\/\//g, '#')}${suffix}`;
});

// Write back to disk.
await fs.writeFile(bindingGypPath, finalised.join('\n'), 'utf8');
