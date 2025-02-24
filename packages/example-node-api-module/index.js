const {dlopen} = require('node:process');
const {constants} = require('node:os');
const path = require('node:path');

function loadAddon(platform = determinePlatform()) {
  if (!platform) {
    throw new Error("Unable to figure out which platform we're on.");
  }

  /** @type {import("./index")} */
  let addon;

  switch (platform) {
    case 'darwin': {
      // XCFramework binaries don't normally have file extensions (e.g. .node),
      // and I'd rather not introduce a post-build step to patch the
      // XCFrameworks to add symlinks in. It feels most sensible to try to use
      // them as-is. So require() might be out of the question.
      // addon = require('./build/universal/addon.xcframework/macos-arm64_x86_64/addon.framework/Versions/Current/addon');

      const module = {exports: {}};
      dlopen(
        module,
        path.join(
          __dirname,
          './build/universal/addon.xcframework/macos-arm64_x86_64/addon.framework/Versions/Current/addon',
        ),
        constants.dlopen.RTLD_NOW,
      );

      addon = module.exports;
      break;
    }
    case 'android': {
      throw new Error('TODO: support Android');
    }
    case 'win32': {
      throw new Error('TODO: support Windows');
    }
    default: {
      throw new Error(`Unsupported platform: ${platform}`);
    }
  }

  return addon;
}

function determinePlatform() {
  /** @type {NodeJS.Platform} */
  let platform;

  for (const lib of [
    () => require('node:os').platform,
    () => require('os').platform,
    () => require('node:process').platform,
    () => require('process').platform,
  ]) {
    try {
      platform = lib();
    } catch (error) {}
  }

  return platform;
}

module.exports.loadAddon = loadAddon;
