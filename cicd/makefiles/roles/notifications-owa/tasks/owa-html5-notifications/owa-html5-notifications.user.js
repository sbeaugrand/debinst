// ==UserScript==
// @name          OWA html5 notifications
// @include       */owa/*
// ==/UserScript==

function owaNotifySend() {
  try {
    var elem = document.querySelector('div[aria-label="conversation"]');
    if (elem == null) {
      return;
    }
    elem = elem.querySelector('div[class*="_lvv_J ms-font-s m"]');
    if (elem == null) {
      return;
    }
    elem = elem.querySelector('span[class*="HighlightSubject"]');
    if (elem == null) {
      return;
    }
    var text = elem.innerHTML;
  } catch (err) {
    var text = err;
  }
  new Notification(text);
}

if (Notification.permission !== "denied") {
  window.setInterval(owaNotifySend, 300000);
}
if (Notification.permission === "default") {
  Notification.requestPermission();
}
