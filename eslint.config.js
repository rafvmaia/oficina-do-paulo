// https://docs.expo.dev/guides/using-eslint/
const { defineConfig } = require('eslint/config');
const expoConfig = require('eslint-config-expo/flat');
const globals = require('globals');
const eslintPluginPrettierRecommended = require('eslint-plugin-prettier/recommended');

module.exports = defineConfig([
  expoConfig,
  eslintPluginPrettierRecommended,
  {
    ignores: ['dist/*', 'android/*', 'ios/*', 'coverage/*', '.expo/*', 'node_modules/*'],
  },
  {
    files: ['**/*.ts', '**/*.tsx'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'error',
    },
  },
  {
    files: ['**/*.test.ts', '**/*.test.tsx', '**/*.test.js'],
    languageOptions: {
      globals: { ...globals.jest },
    },
  },
  {
    files: ['plugins/**/*.js', 'scripts/**/*.mjs', '*.config.js'],
    languageOptions: {
      globals: { ...globals.node },
    },
  },
]);
