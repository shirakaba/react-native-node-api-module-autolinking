function loadAddon(platform = determinePlatform()) {
  if (!platform) {
    throw new Error("Unable to figure out which platform we're on.");
  }

  /** @type {import("./index")} */
  let addon;

  switch (platform) {
    case 'darwin': {
      addon = require('./build/macos/Release/example-node-api-module.node');
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
