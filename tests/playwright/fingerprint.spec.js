const { test, expect } = require('@playwright/test');
const fs = require('fs');
const path = require('path');

const REPORT = 'file://' + path.resolve(__dirname, 'fixture', 'qtl-report.html');
const BASELINE = path.join(__dirname, 'baseline.json');

// Structural fingerprint per chart, in report order: what a renderer swap or a
// data-prep regression would change. Deliberately no pixels.
async function fingerprints(page) {
  await page.goto(REPORT);
  return page.evaluate(() =>
    Array.from(document.querySelectorAll('.gsm-vizr')).map((el, i) => {
      const ch = el.gsmChart;
      const s = ch.data._spec_ || {};
      return {
        index: i,
        labels: ch.data.labels,
        indexAxis: ch.options.indexAxis,
        position: s.position || null,
        stat: s.stat || null,
        title: (s.labels && s.labels.title) || null,
        xLabel: (s.scales && s.scales.x && s.scales.x.label) || null,
        yLabel: (s.scales && s.scales.y && s.scales.y.label) || null,
        captions: s.labels && s.labels.captions ? [].concat(s.labels.captions) : [],
        datasets: ch.data.datasets.map((d) => ({
          label: d.label === undefined ? null : d.label,
          backgroundColor: d.backgroundColor || null,
          data: d.data,
        })),
      };
    })
  );
}

test('the report renders the expected chart set', async ({ page }) => {
  const fps = await fingerprints(page);
  expect(fps).toHaveLength(15);
  // All six migrated functions draw horizontally.
  expect(fps.every((f) => f.indexAxis === 'y')).toBe(true);
  // Only the percentage variant of eligibility_groupBar is normalized to percent.
  expect(fps.filter((f) => f.stat === 'percent')).toHaveLength(1);
});

test('structural fingerprints match the committed baseline', async ({ page }) => {
  const current = await fingerprints(page);
  if (process.env.CAPTURE_BASELINE) {
    fs.writeFileSync(BASELINE, JSON.stringify(current, null, 2) + '\n');
    console.log('Baseline captured:', BASELINE);
    return;
  }
  expect(current).toEqual(JSON.parse(fs.readFileSync(BASELINE, 'utf8')));
});
