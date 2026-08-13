const { test, expect } = require('@playwright/test');
const path = require('path');

const REPORT = 'file://' + path.resolve(__dirname, 'fixture', 'qtl-report.html');

// QTL0001 renders 8 barcharts and QTL0002 renders 7.
const EXPECTED_BARCHARTS = 15;

test('every barchart renders a live chart instance', async ({ page }) => {
  const errors = [];
  page.on('pageerror', (e) => errors.push(String(e)));
  await page.goto(REPORT);

  const live = await page.evaluate(() =>
    Array.from(document.querySelectorAll('.gsm-vizr')).filter((el) => !!el.gsmChart).length
  );

  expect(live).toBe(EXPECTED_BARCHARTS);
  expect(errors).toEqual([]);
});

test('charts in hidden tabs draw once their pane is revealed', async ({ page }) => {
  await page.goto(REPORT);
  // rmarkdown's html_document builds tabsets as Bootstrap 3 tabs.
  const pills = page.locator('a[data-toggle="tab"]');
  const count = await pills.count();
  expect(count).toBe(EXPECTED_BARCHARTS);
  const revealed = new Set();

  for (let i = 0; i < count; i++) {
    const pill = pills.nth(i);
    const target = await pill.getAttribute('href');
    expect(target).toMatch(/^#[A-Za-z0-9_-]+$/);
    await pill.click();

    // Scope the assertion to this pill's target. Two independent tabsets each
    // retain an active pane, so a global ".tab-pane.active" query can keep
    // re-reading the first tabset and falsely pass every chart in the second.
    const pane = page.locator(target);
    await expect(pane).toHaveClass(/active/);
    const widgets = pane.locator('.gsm-vizr');
    expect(await widgets.count()).toBe(1);
    const widgetId = await widgets.first().getAttribute('id');
    expect(widgetId).toBeTruthy();
    revealed.add(widgetId);

    // A revealed canvas can still be mid-layout, and locator.screenshot() times
    // out on a zero-size one, so read the pixels straight off the canvas.
    const canvas = pane.locator('canvas');
    await expect(canvas).toHaveCount(1);
    const drawn = await canvas.evaluate((node) => node.toDataURL().length);
    expect(drawn).toBeGreaterThan(1000);
  }

  expect(revealed.size).toBe(EXPECTED_BARCHARTS);
});
