// -------------------------------------------------------------------------- //
/// \file soleil.js
/// \author Sebastien Beaugrand
/// \sa http://beaugrand.chez.com/
/// \copyright CeCILL 2.1 Free Software license
// -------------------------------------------------------------------------- //
'use strict';

// Lignes "a0 a1 b1 a2 b2 a3 b3" dans l'ordre 0 1 2,
// ou lignes "<index>:<annees>:a0 ..." (sortie de make coeffs).
// Si plusieurs lignes ont le meme index, la derniere l'emporte.
function parse(text) {
    const c = [null, null, null];
    let n = 0;
    for (let line of text.split('\n')) {
        line = line.trim();
        if (line === '') {
            continue;
        }
        let idx = n;
        const colon = line.indexOf(':');
        if (colon >= 0) {
            idx = Number(line.substring(0, colon).trim());
            line = line.substring(line.lastIndexOf(':') + 1).trim();
        }
        const tok = line.split(/\s+/);
        if (!Number.isInteger(idx) || idx < 0 || idx > 2 || tok.length !== 7) {
            return null;
        }
        const v = tok.map(Number);
        if (v.some(Number.isNaN)) {
            return null;
        }
        c[idx] = v;
        ++n;
    }
    return c.includes(null) ? null : c;
}

// Jour de l'annee (1 le 1er janvier)
function dayOfYear(y, m, d) {
    return (Date.UTC(y, m, d) - Date.UTC(y, 0, 1)) / 86400000 + 1;
}

// Meme calcul que result.py : minutes UTC
function minutes(c, y, m, d) {
    const j = dayOfYear(y, m, d);
    const w = 2 * 3.141593 / 365.242365;
    return c[0]
        + c[1] * Math.cos(1 * w * j) + c[2] * Math.sin(1 * w * j)
        + c[3] * Math.cos(2 * w * j) + c[4] * Math.sin(2 * w * j)
        + c[5] * Math.cos(3 * w * j) + c[6] * Math.sin(3 * w * j);
}

// Heure locale "HH:MM" (fuseau et heure d'ete du navigateur)
function localTime(c, y, m, d) {
    const min = Math.floor(minutes(c, y, m, d));
    const t = new Date(Date.UTC(y, m, d) + min * 60000);
    return String(t.getHours()).padStart(2, '0') + ':'
        + String(t.getMinutes()).padStart(2, '0');
}

if (typeof module !== 'undefined') {
    module.exports = { parse, dayOfYear, minutes, localTime };
}
