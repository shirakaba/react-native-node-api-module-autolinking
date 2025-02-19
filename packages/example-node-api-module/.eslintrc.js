module.exports = {
  root: true,
  overrides: [
    {
      env: {
        node: true,
        es2024: true,
      },
      files: ['index.js'],
      parserOptions: {
        sourceType: 'script',
      },
    },
    {
      env: {
        node: true,
        es2024: true,
      },
      files: ['scripts/format-binding.mjs'],
      parserOptions: {
        sourceType: 'module',
      },
    },
  ],
};
