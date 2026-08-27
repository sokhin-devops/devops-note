#!/usr/bin/env node
'use strict';

// A real lint check with zero dependencies — no ESLint install needed, so
// `npm ci` stays instant and works with no network access. It genuinely
// fails the build on two common mistakes: a syntax error, or a stray
// debugger/console.log left in committed code.

const fs = require('node:fs');
const path = require('node:path');
const { execFileSync } = require('node:child_process');

const root = path.join(__dirname, '..');
const dirs = ['src', 'test'];
let problems = 0;

for (const dir of dirs) {
  const full = path.join(root, dir);
  if (!fs.existsSync(full)) continue;

  for (const file of fs.readdirSync(full)) {
    if (!file.endsWith('.js')) continue;
    const filePath = path.join(full, file);
    const rel = path.relative(root, filePath);
    let fileProblems = 0;

    try {
      execFileSync(process.execPath, ['--check', filePath], { stdio: 'pipe' });
    } catch (err) {
      console.error(`x ${rel}: syntax error\n${err.stderr}`);
      fileProblems++;
    }

    const text = fs.readFileSync(filePath, 'utf8');
    if (/\bdebugger\b/.test(text)) {
      console.error(`x ${rel}: contains a 'debugger' statement`);
      fileProblems++;
    }
    if (dir === 'src' && /console\.log\(/.test(text)) {
      console.error(`x ${rel}: contains console.log (allowed in test/, not src/)`);
      fileProblems++;
    }

    if (fileProblems === 0) {
      console.log(`OK ${rel}`);
    }
    problems += fileProblems;
  }
}

if (problems > 0) {
  console.error(`\n${problems} lint problem(s) found`);
  process.exit(1);
}
console.log('\nlint: clean');
