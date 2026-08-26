const { test, expect } = require('@playwright/test');
const path = require('path');

const REPORT = 'file://' + path.resolve(__dirname, 'fixture', 'qtl-report.html');

// QTL0001 and QTL0002 render 7 barcharts each.
const EXPECTED_BARCHARTS = 14;
// One time series per report.
const EXPECTED_TIMESERIES = 2;

// Counts bar elements Chart.js actually laid out with a non-zero footprint.
// gsm.viz stores the live instance on the canvas, so this reads the same
// geometry the renderer drew from.
const countDrawnBars = (canvas) => {
  const chart = canvas.chart;
  if (!chart) return -1;
  return chart.data.datasets.reduce((n, _, di) => {
    const bars = chart.getDatasetMeta(di).data || [];
    return n + bars.filter((b) => b.width > 0 && b.height > 0).length;
  }, 0);
};

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

    // Canvas pixels are the wrong signal here: an untouched canvas this size
    // still encodes to tens of thousands of data-URL characters. Assert on the
    // laid-out bar elements instead, which only exist once bars are drawn.
    const canvas = pane.locator('canvas');
    await expect(canvas).toHaveCount(1);
    expect(await canvas.evaluate(countDrawnBars)).toBeGreaterThan(0);
  }

  expect(revealed.size).toBe(EXPECTED_BARCHARTS);
});

test('the time series widgets draw under the shared gsm.viz bundle', async ({ page }) => {
  // The vendored bundle was removed in favour of gsm.vizr's copy. A widget that
  // silently renders nothing under the shared bundle would still satisfy the
  // dependency-metadata test in tests/testthat/test-vizr-dependency.R, so the
  // check has to reach the drawn chart.
  const errors = [];
  page.on('pageerror', (e) => errors.push(String(e)));
  await page.goto(REPORT);

  const series = await page.evaluate(() =>
    Array.from(document.querySelectorAll('.Widget_TimeSeriesQTL')).map((el) => {
      const chart = el.querySelector('canvas') && el.querySelector('canvas').chart;
      if (!chart || !chart.chartArea) return null;
      const { top, bottom, left, right } = chart.chartArea;
      const points = chart.data.datasets.reduce((n, _, di) => {
        const drawn = (chart.getDatasetMeta(di).data || []).filter(
          (p) => Number.isFinite(p.x) && Number.isFinite(p.y)
        );
        return n + drawn.length;
      }, 0);
      return { id: el.id, width: right - left, height: bottom - top, points };
    })
  );

  expect(series).toHaveLength(EXPECTED_TIMESERIES);
  for (const s of series) {
    expect(s).not.toBeNull();
    expect(s.width).toBeGreaterThan(0);
    expect(s.height).toBeGreaterThan(0);
    expect(s.points).toBeGreaterThan(0);
  }
  expect(errors).toEqual([]);
});
