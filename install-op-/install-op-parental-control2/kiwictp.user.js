// ==UserScript==
// @name          kiwictp
// @include       */*
// ==/UserScript==

function ctparSend() {
    fetch('http://10.66.0.2/log.php',
          {
            method: 'post',
            headers: { 'content-type': 'application/x-www-form-urlencoded' },
            body: 't=' + encodeURIComponent(document.title),
            signal: AbortSignal.timeout(5000)
          }
         ).catch(err => { console.log(err); });
}

window.onload = ctparSend;
