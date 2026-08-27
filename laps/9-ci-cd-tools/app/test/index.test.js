'use strict';

const test = require('node:test');
const assert = require('node:assert/strict');
const { greet, add } = require('../src/index.js');

test('greet() returns a friendly message', () => {
  assert.equal(greet('World'), 'Hello, World!');
});

test('greet() rejects an empty string', () => {
  assert.throws(() => greet(''), TypeError);
});

test('add() adds two numbers', () => {
  assert.equal(add(2, 3), 5);
});

test('add() rejects non-numbers', () => {
  assert.throws(() => add('2', 3), TypeError);
});
