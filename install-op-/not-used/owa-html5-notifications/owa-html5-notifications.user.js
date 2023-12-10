// ==UserScript==
// @name          OWA html5 notifications
// @include       */owa/*
// ==/UserScript==

function notify_send()
{
    try {
        var elem = document.querySelector('div[aria-label*="non lus"]');
        if (elem == null) {
            return;
        }
        var text = elem.getAttribute("aria-label");
    } catch (err) {
        var text = err;
    }
    new Notification(text);
}

window.setInterval(notify_send, 60000);
