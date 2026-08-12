const componentClasses = typeof Components !== "undefined" && Components.classes;
const serviceNamespace = typeof Services !== "undefined" ? Services : null;
if (!componentClasses && !serviceNamespace) {
  document.getElementById("firewall-state").textContent = "Browser API unavailable";
  throw new Error("WolfPack settings requires a privileged browser page");
}

const Cc = componentClasses;
const Ci = typeof Components !== "undefined" ? Components.interfaces : null;
const Cu = typeof Components !== "undefined" ? Components.utils : null;
document.getElementById("firewall-state").textContent = serviceNamespace
  ? "Services available"
  : "XPCOM available";
let PREFS;
let DIRECTORIES;
let STARTUP;
try {
  PREFS = serviceNamespace ? serviceNamespace.prefs : Cc["@mozilla.org/preferences-service;1"].getService(Ci.nsIPrefBranch);
  DIRECTORIES = serviceNamespace ? serviceNamespace.dirsvc : Cc["@mozilla.org/file/directory_service;1"].getService(Ci.nsIProperties);
  STARTUP = serviceNamespace ? serviceNamespace.startup : Cc["@mozilla.org/toolkit/app-startup;1"].getService(Ci.nsIAppStartup);
} catch (error) {
  document.getElementById("firewall-state").textContent = "Browser services unavailable";
  document.getElementById("firewall-status").textContent = error.message;
  throw error;
}

let AddonManager = null;
if (typeof ChromeUtils !== "undefined" && ChromeUtils.importESModule) {
  try {
    ({ AddonManager } = ChromeUtils.importESModule("resource://gre/modules/AddonManager.sys.mjs"));
  } catch (error) {
    AddonManager = null;
  }
} else if (Cu && Cu.importESModule) {
  try {
    ({ AddonManager } = Cu.importESModule("resource://gre/modules/AddonManager.sys.mjs"));
  } catch (error) {
    AddonManager = null;
  }
} else if (Cu && Cu.import) {
  try {
    ({ AddonManager } = Cu.import("resource://gre/modules/AddonManager.jsm", {}));
  } catch (error) {
    AddonManager = null;
  }
}

// The build replaces this empty array with the validated wolfpack.cfg extension list.
const BUNDLED_EXTENSIONS = [];
const FIREWALL_CSP = "default-src 'none'; script-src 'none'; object-src 'none';";
const FIREWALL_PREFS = [
  "extensions.webextensions.base-content-security-policy",
  "extensions.webextensions.base-content-security-policy.v3"
];

const resetButton = document.getElementById("reset-button");
const resetStatus = document.getElementById("reset-status");
const firewallToggle = document.getElementById("firewall-toggle");
const firewallApply = document.getElementById("firewall-apply");
const firewallState = document.getElementById("firewall-state");
const firewallStatus = document.getElementById("firewall-status");
const extensionList = document.getElementById("extension-list");

function setStatus(element, message, isError = false) {
  element.textContent = message;
  element.style.color = isError ? "var(--warning)" : "var(--success)";
}

function getProfile() {
  return DIRECTORIES.get("ProfD", Ci.nsIFile);
}

function getProfilePath() {
  return getProfile().path;
}

function profileFile(fileName) {
  const file = getProfile();
  file.append(fileName);
  return file;
}

function readUtf8(file) {
  const input = Cc["@mozilla.org/network/file-input-stream;1"]
    .createInstance(Ci.nsIFileInputStream);
  input.init(file, 0x01, 0, 0);
  const converter = Cc["@mozilla.org/intl/converter-input-stream;1"]
    .createInstance(Ci.nsIConverterInputStream);
  converter.init(input, "UTF-8", 0, Ci.nsIConverterInputStream.DEFAULT_REPLACEMENT_CHARACTER);
  let result = "";
  const buffer = {};
  while (converter.readString(8192, buffer)) {
    result += buffer.value;
  }
  converter.close();
  return result;
}

function writeUtf8(file, value) {
  const output = Cc["@mozilla.org/network/file-output-stream;1"]
    .createInstance(Ci.nsIFileOutputStream);
  output.init(file, 0x02 | 0x08 | 0x20, 0o600, 0);
  const converter = Cc["@mozilla.org/intl/converter-output-stream;1"]
    .createInstance(Ci.nsIConverterOutputStream);
  converter.init(output, "UTF-8", 0, 0);
  converter.writeString(value);
  converter.close();
}

function ensureDirectory(directory) {
  if (!directory.exists()) {
    directory.create(Ci.nsIFile.DIRECTORY_TYPE, 0o700);
  }
}

function readFirewallState() {
  return FIREWALL_PREFS.some(prefName => {
    try {
      return PREFS.getCharPref(prefName) === FIREWALL_CSP;
    } catch (error) {
      return false;
    }
  });
}

function renderFirewallState(enabled) {
  firewallToggle.checked = enabled;
  firewallState.textContent = enabled ? "Enabled" : "Disabled";
  firewallState.style.color = enabled ? "var(--warning)" : "var(--success)";
}

function applyFirewall() {
  firewallApply.disabled = true;
  try {
    if (firewallToggle.checked) {
      for (const prefName of FIREWALL_PREFS) {
        PREFS.setCharPref(prefName, FIREWALL_CSP);
      }
      renderFirewallState(true);
      setStatus(firewallStatus, "Firewall enabled. Reload extensions or restart the browser to apply it everywhere.");
    } else {
      for (const prefName of FIREWALL_PREFS) {
        if (PREFS.prefHasUserValue(prefName)) {
          PREFS.clearUserPref(prefName);
        }
      }
      renderFirewallState(false);
      setStatus(firewallStatus, "Firewall disabled for this profile. Reload extensions or restart the browser to apply it everywhere.");
    }
  } catch (error) {
    setStatus(firewallStatus, `Could not change the firewall: ${error.message}`, true);
    renderFirewallState(readFirewallState());
  } finally {
    firewallApply.disabled = false;
  }
}

function createExtensionRow(extension, addon) {
  const row = document.createElement("div");
  row.className = "extension-row";

  const label = document.createElement("label");
  const checkbox = document.createElement("input");
  checkbox.type = "checkbox";
  checkbox.checked = Boolean(addon && !addon.userDisabled);
  checkbox.disabled = !addon || !AddonManager;

  const text = document.createElement("span");
  const name = document.createElement("strong");
  name.textContent = extension.name;
  const detail = document.createElement("small");
  detail.textContent = addon
    ? (extension.id || addon.id)
    : "Manage availability in the Add-ons Manager";
  text.append(name, detail);
  label.append(checkbox, text);
  row.append(label);

  if (addon && AddonManager) {
    checkbox.addEventListener("change", async () => {
      checkbox.disabled = true;
      try {
        if (checkbox.checked) {
          await addon.enable();
        } else {
          await addon.disable();
        }
        setStatus(firewallStatus, `${extension.name} is now ${checkbox.checked ? "enabled" : "disabled"}.`);
      } catch (error) {
        checkbox.checked = !checkbox.checked;
        setStatus(firewallStatus, `Could not change ${extension.name}: ${error.message}`, true);
      } finally {
        checkbox.disabled = false;
      }
    });
  } else {
    const manage = document.createElement("a");
    manage.href = "about:addons";
    manage.textContent = "Manage";
    row.append(manage);
  }

  return row;
}

async function loadExtensions() {
  extensionList.replaceChildren();
  if (BUNDLED_EXTENSIONS.length === 0) {
    const empty = document.createElement("p");
    empty.className = "muted";
    empty.textContent = "No bundled extension metadata was embedded in this build.";
    extensionList.append(empty);
    return;
  }

  const ids = BUNDLED_EXTENSIONS.map(extension => extension.id).filter(Boolean);
  let addons = [];
  if (AddonManager && ids.length) {
    try {
      addons = await AddonManager.getAddonsByIDs(ids);
    } catch (error) {
      setStatus(firewallStatus, `Could not read installed extensions: ${error.message}`, true);
    }
  } else if (!AddonManager) {
    setStatus(firewallStatus, "Extension availability can be managed from the Add-ons Manager.");
  }
  const addonsById = new Map(addons.filter(Boolean).map(addon => [addon.id, addon]));
  for (const extension of BUNDLED_EXTENSIONS) {
    extensionList.append(createExtensionRow(extension, addonsById.get(extension.id)));
  }
}

function backupAndRemove(profile, backup, fileName) {
  const source = profileFile(fileName);
  if (source.exists()) {
    source.copyTo(backup, source.leafName);
    source.remove(false);
  }
}

function resetProfile() {
  if (!window.confirm("Reset WolfPack settings and restart now? A backup will be kept in the profile.\n\nBookmarks, history, cookies, saved logins, and downloads will not be removed.")) {
    return;
  }

  resetButton.disabled = true;
  try {
    const profile = getProfile();
    const timestamp = new Date().toISOString().replace(/[.:]/g, "-");
    const backupRoot = profile.clone();
    backupRoot.append("WolfPack-Reset-Backups");
    ensureDirectory(backupRoot);
    const backup = backupRoot.clone();
    backup.append(timestamp);
    ensureDirectory(backup);

    for (const fileName of [
      "prefs.js",
      "prefs-1.js",
      "user-overrides.js",
      "extension-preferences.json",
      "extension-settings.json",
      "search.json.mozlz4"
    ]) {
      backupAndRemove(profile, backup, fileName);
    }

    const userJs = profileFile("user.js");
    if (userJs.exists()) {
      userJs.copyTo(backup, userJs.leafName);
      const managedOnly = readUtf8(userJs).replace(/\r?\n\/\/ WolfPack user-overrides\.js[\s\S]*$/m, "");
      writeUtf8(userJs, managedOnly + "\n");
    }

    setStatus(resetStatus, `Backup saved to ${backup.path}. Restarting with WolfPack defaults…`);
    window.setTimeout(() => {
      STARTUP.quit(Ci.nsIAppStartup.eAttemptQuit | Ci.nsIAppStartup.eRestart);
    }, 500);
  } catch (error) {
    setStatus(resetStatus, `Reset failed: ${error.message}`, true);
    resetButton.disabled = false;
  }
}

renderFirewallState(readFirewallState());
resetButton.addEventListener("click", resetProfile);
firewallApply.addEventListener("click", applyFirewall);
loadExtensions();
