// -------------------------------------------------------------------------- //
/// \file test.js
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// -------------------------------------------------------------------------- //
// Meme sortie que 'make test' dans fourier : lever, meridien, coucher
'use strict';
const { parse, dayOfYear, localTime, coordMinutes } = require('./soleil.js');
const assert = require('assert');

assert.strictEqual(dayOfYear(2024, 2, 1), 61);
assert.strictEqual(dayOfYear(2100, 2, 1), 60);
assert.strictEqual(dayOfYear(2026, 11, 31), 365);
assert.strictEqual(parse('1 2 3'), null);

// Coordonnees : Paris, 21 juin 2026, minutes UTC
const paris = { lat: 48.85, lon: 2.35, h0: -0.833 };
assert.strictEqual(Math.floor(coordMinutes(1, paris, 2026, 5, 21)), 3 * 60 + 46);
assert.strictEqual(Math.floor(coordMinutes(2, paris, 2026, 5, 21)), 19 * 60 + 57);
assert.strictEqual(coordMinutes(1, { lat: 70, lon: 20, h0: -0.833 }, 2026, 5, 21), null);

const c = parse(require('fs').readFileSync(0, 'utf8'));
const n = new Date();
for (const i of [1, 0, 2]) {
    console.log(localTime(c[i], n.getFullYear(), n.getMonth(), n.getDate()));
}
