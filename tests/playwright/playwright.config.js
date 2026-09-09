const { defineConfig } = require('@playwright/test');
// Assertions are DOM/data-structure based (no pixel snapshots), so the suite is
// portable across machines and headless-chromium versions.
module.exports = defineConfig({
  testDir: '.',
  use: { headless: true },
});
