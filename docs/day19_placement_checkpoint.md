# Day 19 — Placement Checkpoint and Candidate Selection

**Date:** 25 November 2026
**Design:** `matmul_top`
**Platform:** Sky130HD
**Selected candidate:** Experiment B

## 1. Objective

Close the placement optimization phase by selecting one candidate for the
subsequent Clock Tree Synthesis (CTS) stage. Preserve the exact detailed-
placement database, its SDC, the configuration, reports, logs and metrics.

## 2. Selected configuration

| Parameter | Selected value |
|---|---:|
| Core utilization | 40% |
| Aspect ratio | 1.0 |
| Placement density | 0.60 |
| Platform | Sky130HD |
| Design | `matmul_top` |

The archived configuration is `config_expB_util40.mk`. It was compared
against the active ORFS configuration, and both files were identical.

## 3. Candidate comparison

The following results were collected at the detailed-placement stage, except
weighted congestion, which is the global-placement metric.

| Metric | B: density 0.60 | G: density 0.55 | H: density 0.65 |
|---|---:|---:|---:|
| Weighted GP congestion | 0.787743 | 0.700949 | 0.833087 |
| Detailed-placement HPWL (um) | 208,319.4 | 214,079.5 | 202,801.5 |
| Estimated route wirelength (um) | 217,169 | 222,724 | 211,731 |
| Detailed-placement area (um^2) | 127,883 | 127,814 | 127,811 |
| Setup slack (ns) | +1.45694 | +1.36023 | +1.42477 |
| Hold slack (ns) | +0.111435 | +0.120266 | +0.424804 |
| Fmax (MHz) | 117.054 | 115.744 | 116.615 |
| Maximum-slew violations | 0 | 4 | 10 |
| Maximum-capacitance violations | 0 | 0 | 0 |
| Maximum-fanout violations | 0 | 0 | 0 |
| Placement-legality violations | 0 | 0 | 0 |

## 4. Selection rationale

Experiment B is retained as the best overall balance for the transition to CTS.

- B has the highest Fmax and the strongest setup slack among the three
  candidates.
- B reports zero maximum-slew, maximum-capacitance, maximum-fanout and
  placement-legality violations.
- G provides the lowest weighted congestion, but has worse HPWL, estimated
  route wirelength, setup slack and Fmax than B.
- H provides the lowest HPWL and estimated route wirelength, but has lower
  setup slack and Fmax than B, and reports 10 maximum-slew violations.

The density experiments therefore do not justify replacing B with G or H.

## 5. Frozen checkpoint

The selected detailed-placement database is:

`results/day19_expB/3_place.odb`

Its corresponding constraints are:

`results/day19_expB/3_place.sdc`

The archive is stored under:

- `reports/day19_placement_checkpoint/expB/`
- `results/day19_expB/`

The report archive contains the selected configuration, floorplan and
placement reports, placement-stage logs, metrics JSON files, a README and a
SHA-256 checksum manifest.

All archived files passed checksum verification after the archive was
created. The `.odb` database is retained locally and excluded from Git; its
checksum remains in the manifest for local integrity checks.

## 6. Checkpoint boundary and next stage

This is a **pre-CTS detailed-placement checkpoint**. It does not represent
post-CTS timing, routed timing, extracted parasitics or final signoff.

The selected database will be the starting placement checkpoint for the
CTS stage. Any later CTS or timing-optimization changes should be evaluated
as new stages rather than silently modifying this frozen checkpoint.

## 7. Reproduction and verification

The archive can be recreated from the active ORFS run using:

`scripts/archive_day19_placement_checkpoint.sh`

From the repository root, verify the archived files with:

`sha256sum -c reports/day19_placement_checkpoint/expB/SHA256SUMS`
