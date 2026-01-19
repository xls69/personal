// Various settings for URL suggestions
user_pref("browser.urlbar.quicksuggest.enabled", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.urlbar.suggest.trending", false);
user_pref("browser.urlbar.suggest.weather", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.history", true);
user_pref("browser.urlbar.suggest.bookmark", true);
user_pref("browser.urlbar.suggest.bestmatch", false);
user_pref("browser.urlbar.suggest.addons", false);
user_pref("browser.urlbar.suggest.pocket", false);

// Disable "Pocket"
user_pref("extensions.pocket.enabled", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);

// Disable Firefox Ads
user_pref("identity.fxaccounts.enabled", false);
user_pref("identity.fxaccounts.toolbar.enabled", false);
user_pref("browser.urlbar.groupLabels.enabled", false);

// Remove bookmark things
user_pref("browser.bookmarks.restore_default_bookmarks", false);
user_pref("browser.bookmarks.file", "");
user_pref("browser.bookmarks.addedImportButton", false);

// Clear EVERYTHING on shutdown (max security) (v2 & old)
user_pref("privacy.clearOnShutdown_v2.cache", true);
user_pref("privacy.clearOnShutdown_v2.historyFormDataAndDownloads", true);
user_pref("privacy.clearOnShutdown_v2.siteSettings", true);
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", true);
user_pref("privacy.clearOnShutdown_v2.downloads", true);
user_pref("privacy.clearOnShutdown_v2.formdata", true);
user_pref("privacy.clearOnShutdown_v2.cookiesAndStorage", true);
user_pref("privacy.clearSiteData.cache", true);
user_pref("privacy.clearSiteData.cookiesAndStorage", true);
user_pref("privacy.clearSiteData.historyFormDataAndDownloads", true);
user_pref("privacy.clearSiteData.siteSettings", true);
user_pref("privacy.clearSiteData.browsingHistoryAndDownloads", true);
user_pref("privacy.clearSiteData.formdata", true);
user_pref("privacy.clearHistory.cache", true);
user_pref("privacy.clearHistory.cookiesAndStorage", true);
user_pref("privacy.clearHistory.historyFormDataAndDownloads", true);
user_pref("privacy.clearHistory.siteSettings", true);
user_pref("privacy.clearHistory.browsingHistoryAndDownloads", true);
user_pref("privacy.clearHistory.formdata", true);
user_pref("privacy.sanitize.sanitizeOnShutdown", true);
user_pref("privacy.sanitize.timeSpan", 0);

// Disable picture-in-picture (very annoying feature)
user_pref("media.videocontrols.picture-in-picture.enabled", false);

// Do not ask to save passwords
user_pref("signon.rememberSignons", false);

// DoH Quad9
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");
user_pref("network.trr.custom_uri", "https://dns.quad9.net/dns-query");