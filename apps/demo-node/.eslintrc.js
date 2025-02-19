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
        sourceType: 'module',
      },
    },
  ],
};
