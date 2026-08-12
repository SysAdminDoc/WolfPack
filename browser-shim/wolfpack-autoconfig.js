// Dependency-free startup registration for the WolfPack settings page.
// Do not import Services or other modules from autoconfig: that can delay startup.
(function() {
  var Cc = Components.classes;
  var Ci = Components.interfaces;
  var Cr = Components.results;
  var io = Cc["@mozilla.org/network/io-service;1"]
    .getService(Ci.nsIIOService);
  var directories = Cc["@mozilla.org/file/directory_service;1"]
    .getService(Ci.nsIProperties);
  var appDir = directories.get("GreD", Ci.nsIFile);
  var wolfpackDir = appDir.clone();
  wolfpackDir.append("browser");
  wolfpackDir.append("wolfpack");

  var resource = Cc["@mozilla.org/network/protocol;1?name=resource"]
    .getService(Ci.nsIResProtocolHandler);
  resource.setSubstitution("wolfpack", io.newFileURI(wolfpackDir));

  var registrar = Components.manager.QueryInterface(Ci.nsIComponentRegistrar);
  var chromeManifest = appDir.clone();
  chromeManifest.append("wolfpack.manifest");
  if (chromeManifest.exists()) {
    try {
      registrar.autoRegister(chromeManifest);
    } catch (e) {
      // The about module can still use the resource substitution below.
    }
  }
  var classId = Components.ID("{b5c51db9-82f0-4c55-9e4a-3a6cfb1bc5c1}");
  var contractId = "@mozilla.org/network/protocol/about;1?what=wolfpack";

  function WolfPackAbout() {}
  WolfPackAbout.prototype = {
    classDescription: "WolfPack settings page",
    classID: classId,
    contractID: contractId,
    QueryInterface: function(iid) {
      if (iid.equals(Ci.nsISupports) || iid.equals(Ci.nsIAboutModule)) {
        return this;
      }
      throw Cr.NS_ERROR_NO_INTERFACE;
    },
    getURIFlags: function() {
      return Ci.nsIAboutModule.ALLOW_SCRIPT |
        Ci.nsIAboutModule.IS_SECURE_CHROME_UI;
    },
    newChannel: function(uri, loadInfo) {
      var contentUri = io.newURI("chrome://wolfpack/content/wolfpack.xhtml", null, null);
      // Follow Firefox's own about redirectors: preserve the caller's load
      // info while resolving a chrome UI resource. The chrome registry keeps
      // the resulting channel in the privileged browser context.
      var channel = io.newChannelFromURIWithLoadInfo(contentUri, loadInfo);
      channel.originalURI = uri;
      return channel;
    }
  };

  var factory = {
    createInstance: function(outer, iid) {
      return new WolfPackAbout();
    },
    QueryInterface: function(iid) {
      if (iid.equals(Ci.nsISupports) || iid.equals(Ci.nsIFactory)) {
        return this;
      }
      throw Cr.NS_ERROR_NO_INTERFACE;
    },
    lockFactory: function() {}
  };

  try {
    registrar.registerFactory(classId, "WolfPack settings page", contractId, factory);
  } catch (e) {
    // The packaged component manifest may already own the contract.
  }
})();
