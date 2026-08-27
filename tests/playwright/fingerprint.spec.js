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
  expect(fps).toHaveLength(14);
  // All six migrated functions draw horizontally.
  expect(fps.every((f) => f.indexAxis === 'y')).toBe(true);
  // No pre-normalized chart remains: the former "Site (by %)" tab is covered
  // by the Site chart's position toggle.
  expect(fps.filter((f) => f.stat === 'percent')).toHaveLength(0);
});

// Widest stacked span per category, as a fraction of the plot width. Percent
// mode fills every category edge to edge; counts mode does not.
async function categorySpans(page, index) {
  return page.evaluate((i) => {
    const chart = document.querySelectorAll('.gsm-vizr')[i].gsmChart;
    const { left, right } = chart.chartArea;
    return chart.data.labels.map((_, li) => {
      const end = chart.data.datasets.reduce((max, _, di) => {
        const bar = chart.getDatasetMeta(di).data[li];
        return bar ? Math.max(max, bar.x) : max;
      }, -Infinity);
      return (end - left) / (right - left);
    });
  }, index);
}

test('the Site chart offers the position toggle that replaced the "(by %)" tab', async ({ page }) => {
  await page.goto(REPORT);
  // gsm.viz draws the toggle on the canvas rather than as a DOM control, and
  // enables it from the spec: a mapped fill, interactivity left on, and a
  // position other than "layer". Losing any of those silently removes the only
  // route to the percentage view now that the separate tab is gone.
  const spec = await page.evaluate(() => {
    const s = document.querySelector('.gsm-vizr').gsmChart.data._spec_;
    return { fill: s.mapping && s.mapping.fill, interactive: s.interactive, position: s.position };
  });

  expect(spec.fill).toBeTruthy();
  expect(spec.interactive).not.toBe(false);
  expect(spec.position).not.toBe('layer');
});

test('percentage mode normalizes every category to the full width', async ({ page }) => {
  await page.goto(REPORT);
  const counts = await categorySpans(page, 0);
  expect(counts.length).toBeGreaterThan(0);
  // Counts mode scales to the largest category, so the rest fall short.
  expect(Math.min(...counts)).toBeLessThan(0.99);

  // The same update the toggle's click handler issues for the "fill" icon. It
  // has to beat the chart's own stat = "identity"; if that wins the merge the
  // bars keep drawing raw counts.
  await page.evaluate(() => {
    const chart = document.querySelector('.gsm-vizr').gsmChart;
    chart.helpers.updateSpec(chart, { position: 'stack', stat: 'percent' });
  });
  const percent = await categorySpans(page, 0);
  for (const span of percent) {
    expect(span).toBeCloseTo(1, 3);
  }

  // And back to counts, so the toggle is not a one-way trip.
  await page.evaluate(() => {
    const chart = document.querySelector('.gsm-vizr').gsmChart;
    chart.helpers.updateSpec(chart, { position: 'stack', stat: 'count' });
  });
  expect(Math.min(...(await categorySpans(page, 0)))).toBeLessThan(0.99);
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
