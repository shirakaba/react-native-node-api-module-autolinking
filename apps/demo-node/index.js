const {
  loadAddon,
} = require('@react-native-node-api-module-autolinking/example-node-api-module');
const {add} = loadAddon();

console.log(add(1, 2));
