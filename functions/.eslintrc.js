module.exports = {
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2020, // 🔄 Upgrade from 2018 to 2020 (optional, for nullish coalescing, optional chaining etc.)
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", { allowTemplateLiterals: true }],
    "require-jsdoc": "off", // ✅ Turn off JSDoc requirement (Google style enforces this)
    "max-len": ["warn", { code: 120 }], // ✅ Allow longer lines
    "no-unused-vars": ["warn"], // ✅ Just warn on unused variables
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};
