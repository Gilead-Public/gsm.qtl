# IntroQTL

## `gsm.qtl` – Introduction to Quality Tolerance Limit (QTL) Analysis

The **`gsm.qtl`** package is a specialized module within the Gilead
Statistical Monitoring (GSM) framework, focusing on the **Quality
Tolerance Limit (QTL)** analysis. It is designed to detect atypical
trends of metric at study-level as an indication of potential data
integrity or patient safety concerns using pre-specified or data-driven
thresholds.

------------------------------------------------------------------------

### Workflows Overview

`gsm.qtl` mirrors the modular design of the GSM ecosystem. A typical
workflow includes:

1.  **Data Ingestion**  
    Load participant-level trial data (e.g., deviations).

2.  **Summarization**  
    Aggregate data into study‑level metrics such as rates of deviations,
    etc.

3.  **Threshold Detection**  
    Compare each study’s metrics to **QTL thresholds** using:

    - Z‑score calculations with optional overdispersion adjustments

4.  **Flagging**  
    Assign **risk levels** (Red / Green) based on breaches of the
    thresholds.

5.  **Visualization & Reporting**  
    Produce interactive HTML reports with charts, summary tables, and
    filters for exploration.

------------------------------------------------------------------------

### Why Use `gsm.qtl`?

- **Modular & Compliant**  
  Leverages the qualified GSM statistical engine with unit testing and
  familiar reports/outputs.

- **Flexible Thresholds**  
  Supports both *static QTLs* (predefined in YAML) and *data-driven
  cutoffs* (z-scores, quantiles).

- **End-to-End Reporting**  
  Generates clean, reproducible outputs that can be embedded into trial
  oversight reports.

------------------------------------------------------------------------

### Statistical Methods for Threshold Flagging

The default statistical method applies normal approximation of binomial
distribution to the binary outcome as dynamic thresholds. This method is
particularly useful for monitoring binary outcomes, such as proportion
of participants with eligibility-related deviations or early study
discontinuation, where the goal is to identify studies that deviate
significantly from expected rates.

For each study, a **proportion metric** is calculated as

``` math
\hat{p} = \frac{\text{num}}{\text{denom}},
```

where **num** is the number of observed events of interest (e.g.,
participants with protocol deviations related to eligibility, early
study discontinuation) and **denom** is the relevant denominator (e.g.,
total participants).

This observed proportion is compared against a **predefined QTL
threshold** that is calculated as the following.

The expected mean of QTL, $`p_0`$, typically derived from historical
trial data (e.g., 0.05). This expected mean, $`p_0`$, will be
configurable in the workflows from study to study, denoted as
`nPropRate` in each analysis `yaml`’s `meta` field.

To account for natural variability, a **tolerance margin** is added to
the threshold based on a normal approximation to the binomial
distribution:

``` math
\text{Tolerance Margin} = \text{z} \times \sqrt{\frac{p_0(1 - p_0)}{\text{denom}}}.
```

Here, $`z`$, which will also be configurable denoted as `nNumDeviations`
in the `yaml`’s `meta` field, controls the leniency of the threshold.

An excursion from the **QTL** limit is flagged when

``` math
\hat{p} > p_0 + \text{z} \times \sqrt{\frac{p_0(1 - p_0)}{\text{denom}}}.
```

This approach is conceptually similar to a one-sided control limit
around the expected rate $`p_0`$. Studies exceeding this adjusted limit
are **flagged for further review** as potential outliers in the
monitored metric.
