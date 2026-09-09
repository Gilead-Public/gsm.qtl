function timeSeriesQTL(
  el,
  results,
  config,
  thresholds,
  intervals,
  groupMetadata
) {
  const ALWAYS = ["Upper_funnel", "flat_line"];
  const THRESHOLD_LABELS = {
    Upper_funnel: "QTL Threshold",
    flat_line: "Nominal Threshold"
  };
  const COLOR_ABOVE = "#FF5859";
  const COLOR_BELOW = "#3DAF06";
  const COLOR_FLAT = "#9ca3af";
  const COLOR_METRIC = "#6b7280";

  const ALWAYS_ALIASES = {
    Upper_funnel: ["upper_funnel"],
    flat_line: ["flat_line", "flatline"]
  };

  function normalizeGroupId(groupID) {
    if (groupID === undefined || groupID === null) {
      return null;
    }

    const key = String(groupID).toLowerCase();

    if (ALWAYS_ALIASES.Upper_funnel.includes(key)) {
      return "Upper_funnel";
    }

    if (ALWAYS_ALIASES.flat_line.includes(key)) {
      return "flat_line";
    }

    return groupID;
  }

  function normalizeLabel(text) {
    if (text === undefined || text === null) {
      return text;
    }

    const value = String(text)
      .replace(/\bSite\b/g, "Study")
      .replace(/Green Flag/g, "Below QTL Threshold")
      .replace(/Red Flag/g, "Above QTL Threshold");

    if (/^Upper_funnel$/i.test(value)) {
      return THRESHOLD_LABELS.Upper_funnel;
    }

    if (/^(flat_line|flatline)$/i.test(value)) {
      return THRESHOLD_LABELS.flat_line;
    }

    return value;
  }

  function metricValue(raw, parsed) {
    if (raw && raw.Metric !== undefined && raw.Metric !== null) {
      const num = Number(raw.Metric);
      if (!Number.isNaN(num)) {
        return num;
      }
    }

    if (parsed && parsed.y !== undefined && parsed.y !== null) {
      const num = Number(parsed.y);
      if (!Number.isNaN(num)) {
        return num;
      }
    }

    return null;
  }

  function displayDate(raw, tooltipItem) {
    if (raw && raw.SnapshotDate !== undefined && raw.SnapshotDate !== null) {
      return String(raw.SnapshotDate);
    }

    if (tooltipItem && tooltipItem.label !== undefined && tooltipItem.label !== null) {
      return String(tooltipItem.label);
    }

    return "NA";
  }

  function isAboveThreshold(point) {
    if (!point) {
      return false;
    }

    if (point.Flag !== undefined && point.Flag !== null) {
      const flag = String(point.Flag).toLowerCase();
      if (flag.includes("above qtl threshold") || flag.includes("red flag")) {
        return true;
      }
      if (flag.includes("below qtl threshold") || flag.includes("green flag")) {
        return false;
      }
    }

    const metric = Number(point.Metric);
    const upper = Number(point.Upper_funnel);
    if (!Number.isNaN(metric) && !Number.isNaN(upper)) {
      return metric > upper;
    }

    return false;
  }

  // 2) Build the chart as usual
  const chart = gsmViz.default.timeSeries(
    el, results, config, thresholds, intervals, groupMetadata
  );

  // 3) Helper to strip out distributions
  function stripDistributions() {
    chart.data.datasets = chart.data.datasets.filter(
      ds => ds.purpose !== "distribution"
    );
  }

  // 4) Style threshold lines
  function styleAlways() {
    const metricLabel = (config && config.Abbreviation) ? String(config.Abbreviation) : "Metric";
    let mainMetricLineLabeled = false;

    chart.data.datasets.forEach(ds => {
      const datasetGroupID = ds.data && ds.data[0] ? normalizeGroupId(ds.data[0].GroupID) : null;
      const isThreshold = ALWAYS.includes(datasetGroupID);

      if (ds.label) {
        ds.label = normalizeLabel(ds.label);
      }

      if (ds.name) {
        ds.name = normalizeLabel(ds.name);
      }

      if (
        ds.type === "line" &&
        ds.purpose === "highlight" &&
        isThreshold
      ) {
        ds.label = THRESHOLD_LABELS[datasetGroupID] || ds.label;

        if (datasetGroupID === "Upper_funnel") {
          ds.borderColor = COLOR_ABOVE;
          ds.backgroundColor = COLOR_ABOVE;
          ds.borderDash = [2, 4];
        } else {
          ds.borderColor = COLOR_FLAT;
          ds.backgroundColor = COLOR_FLAT;
          ds.borderDash = [2, 4];
        }

        ds.borderWidth = 1.25;
        ds.pointStyle = "circle";
        ds.pointRadius = 2;
        ds.pointHoverRadius = 4;
        ds.pointHitRadius = 7;
      } else if (ds.type === "line" && ds.purpose === "highlight") {
        ds.borderDash = [];
        ds.borderColor = COLOR_METRIC;
        ds.backgroundColor = COLOR_METRIC;
        ds.segment = {};
        ds.pointRadius = 4;
        ds.pointHoverRadius = 7;
        ds.pointHitRadius = 12;
        ds.pointBackgroundColor = ds.data.map(point => isAboveThreshold(point) ? COLOR_ABOVE : COLOR_BELOW);
        ds.pointBorderColor = ds.pointBackgroundColor;

        if (!mainMetricLineLabeled) {
          ds.label = metricLabel;
          ds.name = metricLabel;
          mainMetricLineLabeled = true;
        }
      }
    });

    if (!chart.options.scales) {
      chart.options.scales = {};
    }

    const yScaleKeys = ["y", "_value_"];
    yScaleKeys.forEach((key) => {
      if (chart.options.scales[key]) {
        if (!chart.options.scales[key].title) {
          chart.options.scales[key].title = {};
        }
        chart.options.scales[key].title.display = true;
        chart.options.scales[key].title.text = metricLabel;
      }
    });

    if (!chart.options.plugins) {
      chart.options.plugins = {};
    }

    if (!chart.options.plugins.tooltip) {
      chart.options.plugins.tooltip = {};
    }

    if (!chart.options.plugins.tooltip.callbacks) {
      chart.options.plugins.tooltip.callbacks = {};
    }

    if (!chart.options.plugins.legend) {
      chart.options.plugins.legend = {};
    }

    if (!chart.options.plugins.legend.labels) {
      chart.options.plugins.legend.labels = {};
    }

    chart.options.plugins.legend.labels.usePointStyle = true;
    chart.options.plugins.legend.labels.boxWidth = 18;

    const defaultGenerateLabels = chart.options.plugins.legend.labels.generateLabels;
    chart.options.plugins.legend.labels.generateLabels = function(currentChart) {
      const generated = typeof defaultGenerateLabels === "function"
        ? defaultGenerateLabels(currentChart)
        : currentChart.data.datasets.map((dataset, index) => ({
            text: dataset.label,
            datasetIndex: index,
            strokeStyle: dataset.borderColor,
            lineDash: dataset.borderDash || []
          }));

      const filtered = generated
        .map(item => {
          const text = normalizeLabel(item.text || "");
          const lower = String(text).toLowerCase();
          const isQtlThreshold = lower === "qtl threshold";
          const isNominalThreshold = lower === "nominal threshold";

          let strokeStyle = item.strokeStyle;
          let lineWidth = item.lineWidth;
          if (isQtlThreshold) {
            strokeStyle = COLOR_ABOVE;
            lineWidth = 2.25;
          } else if (isNominalThreshold) {
            strokeStyle = COLOR_FLAT;
            lineWidth = 2.25;
          }

          return {
            ...item,
            text,
            pointStyle: "line",
            strokeStyle,
            lineWidth
          };
        })
        .filter(item => {
          const text = String(item.text || "").toLowerCase();
          return !text.includes("amber flag") &&
            !text.includes("no flag") &&
            !text.includes("below qtl threshold") &&
            !text.includes("above qtl threshold");
        });

      filtered.push(
        {
          text: "Below QTL Threshold",
          fillStyle: COLOR_BELOW,
          strokeStyle: COLOR_BELOW,
          lineWidth: 0,
          pointStyle: "circle",
          hidden: false,
          datasetIndex: null
        },
        {
          text: "Above QTL Threshold",
          fillStyle: COLOR_ABOVE,
          strokeStyle: COLOR_ABOVE,
          lineWidth: 0,
          pointStyle: "circle",
          hidden: false,
          datasetIndex: null
        }
      );

      return filtered;
    };
    chart.options.plugins.tooltip.callbacks.label = function(tooltipItem) {
      const raw = tooltipItem.raw || {};
      const groupID = normalizeGroupId(raw.GroupID);
      const value = metricValue(raw, tooltipItem.parsed);
      const date = displayDate(raw, tooltipItem);
      const pct = value === null ? "NA" : (value * 100).toFixed(1) + "%";

      if (groupID && ALWAYS.includes(groupID)) {
        return [`Date: ${date}`, `Value: ${pct}`];
      }

      const numerator = raw.Numerator !== undefined && raw.Numerator !== null ? raw.Numerator : "NA";
      const denominator = raw.Denominator !== undefined && raw.Denominator !== null ? raw.Denominator : "NA";

      return [
        `Date: ${date}`,
        `Rate: ${pct}`,
        `Numerator: ${numerator}`,
        `Denominator: ${denominator}`
      ];
    };

    chart.options.plugins.tooltip.callbacks.title = function(items) {
      const first = Array.isArray(items) && items.length > 0 ? items[0] : null;
      const raw = first && first.raw ? first.raw : {};
      const groupID = normalizeGroupId(raw.GroupID);
      if (groupID && ALWAYS.includes(groupID)) {
        return THRESHOLD_LABELS[groupID] || "Threshold";
      }
      return metricLabel;
    };
  }

  // 5) First pass: strip, style, redraw
  stripDistributions();
  styleAlways();
  chart.update();

  // 6) Wrap updateSelectedGroupIDs so we always union in ALL the ALWAYS IDs
  if (chart.helpers.updateSelectedGroupIDs) {
    const orig = chart.helpers.updateSelectedGroupIDs.bind(chart);
    chart.helpers.updateSelectedGroupIDs = ids => {
      const picked = Array.isArray(ids) ? ids : [ids];
      const forced = [...new Set([...ALWAYS, ...picked])];
      orig(forced);
      stripDistributions();
      styleAlways();
      chart.update();
    };
  }

  // 7) Wrap updateData similarly
  if (chart.helpers.updateData) {
    const orig2 = chart.helpers.updateData.bind(chart);
    chart.helpers.updateData = (...args) => {
      orig2(...args);
      stripDistributions();
      styleAlways();
      chart.update();
    };
  }

  // 8) Kick off the very first pass—this will now include *all* ALWAYS IDs
  const initial = Array.isArray(config.selectedGroupIDs)
    ? config.selectedGroupIDs
    : config.selectedGroupIDs ? [config.selectedGroupIDs] : [];
  chart.helpers.updateSelectedGroupIDs(initial);

  return chart;
}

// Registration onto the bundle's internal `main_default` was dead code: that
// name is scoped inside the gsm.viz IIFE and has never been a global, so the
// assignment only ever threw a ReferenceError. Widget_TimeSeriesQTL.js calls
// the global timeSeriesQTL() defined above directly.
