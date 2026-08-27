#!/usr/bin/env node
'use strict';

// Stands in for a real build (bundling, transpiling). Here it just proves
// the module loads and its exports are what callers expect, then writes a
// version-stamped artifact — something for `actions/upload-artifact` to
// actually have a reason to upload.

const fs = require('node:fs');
const path = require('node:path');

const root = path.join(__dirname, '..');
const app = require(path.join(root, 'src', 'index.js'));

if (typeof app.greet !== 'function' || typeof app.add !== 'function') {
  console.error('build failed: src/index.js is missing an expected export');
  process.exit(1);
}

const distDir = path.join(root, 'dist');
fs.mkdirSync(distDir, { recursive: true });

const pkg = JSON.parse(fs.readFileSync(path.join(root, 'package.json'), 'utf8'));
const manifest = {
  name: pkg.name,
  version: pkg.version,
  builtAt: process.env.GITHUB_SHA || 'local-build',
  nodeVersion: process.version,
};

fs.writeFileSync(path.join(distDir, 'build-manifest.json'), JSON.stringify(manifest, null, 2));
console.log('build: wrote dist/build-manifest.json');
console.log(JSON.stringify(manifest, null, 2));
