'use strict';

// A tiny, dependency-free "app" — the point of this lab is the pipeline
// around it, not the app itself. Real enough to lint, test, and build.

function greet(name) {
  if (typeof name !== 'string' || name.trim() === '') {
    throw new TypeError('greet() requires a non-empty string');
  }
  return `Hello, ${name}!`;
}

function add(a, b) {
  if (typeof a !== 'number' || typeof b !== 'number') {
    throw new TypeError('add() requires two numbers');
  }
  return a + b;
}

module.exports = { greet, add };
