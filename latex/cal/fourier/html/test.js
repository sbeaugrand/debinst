// -------------------------------------------------------------------------- //
/// \file test.js
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// -------------------------------------------------------------------------- //
// Meme sortie que 'make test' dans fourier : lever, meridien, coucher
'use strict';
const { parse, dayOfYear, localTime } = require('./soleil.js');
const assert = require('assert');

assert.strictEqual(dayOfYear(2024, 2, 1), 61);
assert.strictEqual(dayOfYear(2100, 2, 1), 60);
assert.strictEqual(dayOfYear(2026, 11, 31), 365);
assert.strictEqual(parse('1 2 3'), null);

const c = parse(require('fs').readFileSync(0, 'utf8'));
const n = new Date();
for (const i of [1, 0, 2]) {
    console.log(localTime(c[i], n.getFullYear(), n.getMonth(), n.getDate()));
}
