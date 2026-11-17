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

// Calcul avec les coordonnees p = { lat, lon, h0 } en degres (Nord et Est
// positifs, h0 hauteur du soleil au lever/coucher, -0.833 pour la refraction
// et le rayon du disque) : minutes UTC du meridien (i = 0), du lever (1) ou
// du coucher (2), null si le soleil ne se leve ou ne se couche pas.
// Equation du temps et declinaison : series de Fourier de Spencer (1971)
// reprises par la NOAA, "General Solar Position Calculations"
// https://gml.noaa.gov/grad/solcalc/solareqns.PDF
function coordMinutes(i, p, y, m, d) {
    const r = Math.PI / 180;
    const g = 2 * Math.PI / dayOfYear(y, 11, 31) * (dayOfYear(y, m, d) - 1);
    const eqtime = 229.18 * (0.000075
        + 0.001868 * Math.cos(g) - 0.032077 * Math.sin(g)
        - 0.014615 * Math.cos(2 * g) - 0.040849 * Math.sin(2 * g));
    const decl = 0.006918
        - 0.399912 * Math.cos(g) + 0.070257 * Math.sin(g)
        - 0.006758 * Math.cos(2 * g) + 0.000907 * Math.sin(2 * g)
        - 0.002697 * Math.cos(3 * g) + 0.00148 * Math.sin(3 * g);
    const noon = 720 - 4 * p.lon - eqtime;
    if (i === 0) {
        return noon;
    }
    const lat = p.lat * r;
    const cosH = (Math.sin(p.h0 * r) - Math.sin(lat) * Math.sin(decl))
        / (Math.cos(lat) * Math.cos(decl));
    if (!(cosH >= -1 && cosH <= 1)) {
        return null;
    }
    const h = Math.acos(cosH) / r;
    return i === 1 ? noon - 4 * h : noon + 4 * h;
}

// Heure locale "HH:MM" (fuseau et heure d'ete du navigateur)
// a partir des minutes UTC du jour
function formatTime(min, y, m, d) {
    const t = new Date(Date.UTC(y, m, d) + Math.floor(min) * 60000);
    return String(t.getHours()).padStart(2, '0') + ':'
        + String(t.getMinutes()).padStart(2, '0');
}

function localTime(c, y, m, d) {
    return formatTime(minutes(c, y, m, d), y, m, d);
}

if (typeof module !== 'undefined') {
    module.exports = { parse, dayOfYear, minutes, localTime,
                       coordMinutes, formatTime };
}
