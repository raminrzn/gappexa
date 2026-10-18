# gappexa

The **GAP index and staging system** for idiopathic pulmonary fibrosis as a
ModelsCloud service. It returns the point total (0–8), the stage (I–III), and
that stage's 1-, 2- and 3-year mortality in the original cohort.

Ley B, Ryerson CJ, Vittinghoff E, et al. A multidimensional index and staging
system for idiopathic pulmonary fibrosis. *Ann Intern Med.*
2012;156(10):684–691.
[doi:10.7326/0003-4819-156-10-201205150-00004](https://doi.org/10.7326/0003-4819-156-10-201205150-00004)

This is the point version only. It does not reproduce the continuous GAP
calculator, ILD-GAP or later revisions.

## Points and stages

| | 0 | 1 | 2 | 3 |
|---|---|---|---|---|
| Sex | female | male | | |
| Age, years | ≤60 | 61–65 | >65 | |
| FVC, % predicted | >75 | 50–75 | <50 | |
| DLCO, % predicted | >55 | 36–55 | ≤35 | unable to perform |

| Stage | Points | 1-year | 2-year | 3-year |
|---|---|---|---|---|
| I | 0–3 | 5.6% | 10.9% | 16.3% |
| II | 4–5 | 16.2% | 29.9% | 42.1% |
| III | 6–8 | 39.2% | 62.1% | 76.8% |

The mortality figures are stage-level estimates from the original derivation
cohort, not individual predictions. A 2023 external validation found that they
overestimate mortality in stage I (Zhang et al., *Clin Respir J* 2023).

## Inputs

| Field | Coding |
|---|---|
| `sex` | `"male"` / `"female"` |
| `age` | completed years (whole number) |
| `fvc` | % predicted (decimals allowed) |
| `dlco` | % predicted (whole number), or `"unable"` if the patient could not perform the test |

Age and DLCO must be whole numbers. The published bands are whole numbers, and
a DLCO of 35.5 falls between "≤35" and "36–55" with no rule for which side it
belongs to. FVC's bands cover every decimal. "Unable to perform" scores 3; a
missing DLCO is an error, not "unable".

## Validation

The points and stage risks were taken from Zhang et al. 2023, supplement
Tables S1–S2. The points were cross-checked against MDCalc. Tests cover every
band edge, every stage boundary and all three risk sets. The tests use
generated patients, not published cases.

## Source and reuse

The original article is not open access. The tables used here come from
Zhang et al. 2023 (CC BY 4.0,
[PMC10500316](https://pmc.ncbi.nlm.nih.gov/articles/PMC10500316/)). This is an
independent implementation of the published point lookup, with citation.

## Use

```r
remotes::install_git("https://github.com/raminrzn/gappexa", ref = "main")
gappexa::model_run(list(sex = "male", age = 68, fvc = 62, dlco = 40))
```

For research use. Not a medical device.

## License

GPL-3.
