// Turn off "Sends data to servers when leaving pages"
user_pref("beacon.enabled", false);

// Prevention of some telemetry related to the newtab
user_pref("browser.newtabpage.directory.ping", "");
user_pref("browser.newtabpage.directory.source", "");
user_pref("browser.newtabpage.enhanced", false);

// "In the release channels the Mozilla location service is used to help in figuring out regional search defaults."
// Which means sending collectable data
user_pref("browser.search.geoip.url", "");
user_pref("browser.search.region", "US");
user_pref("browser.search.suggest.enabled", false);
user_pref("browser.search.update", false);

// Selfsupport sends a heartbeat
user_pref("browser.selfsupport.url", "");

// Datareporting is telemetry
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("datareporting.policy.dataSubmissionEnabled", false);
user_pref("datareporting.sessions.current.clean", true);

// Disables web browser access of HAL sensors
user_pref("device.sensors.enabled", false);

// Prevention of an android ADB Helper Add-on auto installer and other dev tools user_pref("devtools.webide.autoinstallADBHelper", false);
user_pref("devtools.webide.autoinstallFxdtAdapters", false);
user_pref("devtools.webide.enabled", false);
user_pref("devtools.debugger.remote-enabled", false);
user_pref("devtools.chrome.enabled", false);
user_pref("devtools.debugger.force-local", true);

// See https://www.reddit.com/r/privacytoolsIO/comments/3fzbgy/you_may_be_tracked_by_your_battery_status_of_your/
user_pref("dom.battery.enabled", false);

// See https://wiki.mozilla.org/Security/Reviews/Firefox/NavigationTimingAPI
user_pref("dom.enable_performance", false);

// If enabled, your list of installed addons are sent once a day to mozilla
// https://blog.mozilla.org/addons/how-to-opt-out-of-add-on-metadata-updates/
user_pref("extensions.getAddons.cache.enabled", false);

// Disable pocket for obvious reasons
user_pref("extensions.pocket.enabled", false);

// Geo location sends location data
user_pref("geo.enabled", false);
user_pref("geo.wifi.uri", "");

// If you mistype the keyword, then Firefox will leak the content of your address bar to
// the default search engine instead of displaying some "The address wasn't understood" local error page
user_pref("keyword.enabled", false);

// Disable screensharing framework
user_pref("media.getusermedia.screensharing.enabled", false);

// Turn off WebRTC // see https://tinyurl.com/yc3yqnyv
user_pref("media.navigator.enabled", false);
user_pref("media.peerconnection.enabled", false);
user_pref("media.peerconnection.ice.default_address_only", true);

// Disable stat collection
user_pref("media.video_stats.enabled", false);

// Disable DNS prefetching
user_pref("network.dns.disablePrefetch", true);

// Disable speculative loading
user_pref("network.http.speculative-parallel-limit", 0);

// Disable prefetching and predicting
user_pref("network.predictor.cleaned-up", true);
user_pref("network.predictor.enabled", false);
user_pref("network.prefetch-next", false);

// Tracking protection. Though almost always ignored and useless...
user_pref("privacy.donottrackheader.enabled", true);
user_pref("privacy.trackingprotection.enabled", true);
user_pref("privacy.trackingprotection.introCount", 20);

// Overt telemetry disabling
user_pref("devtools.onboarding.telemetry.logged", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("browser.newtabpage.activity-stream.feeds.telemetry", false);
user_pref("browser.newtabpage.activity-stream.telemetry", false);
user_pref("browser.ping-centre.telemetry", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);
user_pref("toolkit.telemetry.enabled", false);
user_pref("toolkit.telemetry.firstShutdownPing.enabled", false);
user_pref("toolkit.telemetry.hybridContent.enabled", false);
user_pref("toolkit.telemetry.newProfilePing.enabled", false);
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.shutdownPingSender.enabled", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.updatePing.enabled", false);
user_pref("toolkit.telemetry.server", "");
user_pref("toolkit.telemetry.reportingpolicy.firstRun", false);
user_pref("toolkit.telemetry.unified", false);
user_pref("toolkit.telemetry.archive.enabled", false);
user_pref("devtools.onboarding.telemetry.logged", false);
user_pref("toolkit.telemetry.bhrPing.enabled", false);

// Disable developer experiments and onboarding
user_pref("browser.onboarding.enabled", false);
user_pref("experiments.enabled", false);
user_pref("network.allow-experiments", false);

// Disable social networking site info exchange
user_pref("social.directories", "");
user_pref("social.remote-install.enabled", false);
user_pref("social.toast-notifications.enabled", false);
user_pref("social.whitelist", "");

// Disable retrieval of safebrowsing lists
user_pref("services.sync.prefs.sync.browser.safebrowsing.malware.enabled", false);
user_pref("services.sync.prefs.sync.browser.safebrowsing.phishing.enabled", false);

// Disable reporting of crash information
user_pref("dom.ipc.plugins.reportCrashURL", false);
user_pref("breakpad.reportURL", "");

// Safebrowsing sends a hash of your url to retrieve a list of partial matches.
user_pref("browser.safebrowsing.blockedURIs.enabled", false);
user_pref("browser.safebrowsing.downloads.enabled", false);
user_pref("browser.safebrowsing.downloads.remote.enabled", false);
user_pref("browser.safebrowsing.malware.enabled", false);
user_pref("browser.safebrowsing.phishing.enabled", false);

// Disable Firefox Screenshots
user_pref("extensions.screenshots.disabled", true);
user_pref("extensions.screenshots.system-disabled", true);
user_pref("extensions.screenshots.upload-disabled", true);

// Enable DNS-over-HTTPS (DoH)
// network.trr.mode turns on DoH. It takes the following values
// 0 - Default value in standard Firefox installations (currently is 5, which means DoH is disabled)
// 1 - DoH is enabled, but Firefox picks if it uses DoH or regular DNS based o which returns faster query responses
// 2 - DoH is enabled, and regular DNS works as a backup
// 3 - DoH is enabled, and regular DNS is disabled
// 5 - DoH is disabled
// Users may want to set to 3 temporarily to verify DoH is working
user_pref("network.trr.mode", 2);
// users can use their own DoH server URL https://github.com/curl/curl/wiki/DNS-over-HTTPS#publicly-available-servers
user_pref("network.trr.uri", "https://mozilla.cloudflare-dns.com/dns-query");
// If DoH doesn't work, try uncommenting the line below (1.1.1.1 is cloudflare, can use google's 8.8.8.8 also)
// user_pref("network.trr.bootstrapAddress", 1.1.1.1);

// ---
// --- Protective but not telemetry or data collection related
// ---

// Disable javascript takeover of mouse menu
user_pref("dom.event.contextmenu.enabled", false);

// Stops leave-page warning
user_pref("dom.disable_beforeunload", true);

// Don't constantly check if its the default browser
user_pref("browser.shell.checkDefaultBrowser", false);

// Keep the full url to see which sites are still http and not https
user_pref("browser.urlbar.trimURLs", false);

// No need to warn us
user_pref("general.warnOnAboutConfig", false);

// Disable automatically updating your extensions (uncomment for settings to take effect)
//user_pref("extensions.update.autoUpdateDefault", false);
//user_pref("extensions.update.enabled", false);

// Disable automatic upgrading to newest version. Program will still ask you if you want to upgrade. (uncomment to activate setting) //user_pref("app.update.auto", false);
//user_pref("app.update.enabled", false);

