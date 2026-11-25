# Day 19 — Placement Checkpoint: Experiment B

Checkpoint date: 2026-11-25

## Selected experiment

- Design: matmul_top
- Platform: Sky130HD
- Experiment: B — 40% core utilization, aspect ratio 1
- Placement density: 0.60
- Configuration: config_expB_util40.mk

## Frozen database

The selected pre-CTS detailed-placement database is:

`results/day19_expB/3_place.odb`

Its corresponding timing constraints are:

`results/day19_expB/3_place.sdc`

## Selection rationale

Experiment B was retained as the best overall balance among B, G and H.

Reported Experiment B placement metrics:

- Setup slack: +1.45694 ns
- Hold slack: +0.111435 ns
- Fmax: 117.054 MHz
- Weighted global-placement congestion: 0.787743
- Detailed-placement HPWL: 208,319.4 um
- Estimated route wirelength: 217,169 um
- Detailed-placement instance area: 127,883 um^2
- Maximum-slew violations: 0
- Maximum-capacitance violations: 0
- Maximum-fanout violations: 0
- Placement-legality violations: 0

Experiment G had lower weighted congestion, but worse HPWL, setup slack and Fmax.
Experiment H had lower HPWL and estimated route wirelength, but worse setup
slack and Fmax, and 10 maximum-slew violations.

## Checkpoint boundary

This is a **pre-CTS placement checkpoint**. Clock-tree synthesis, routing,
parasitic extraction and post-route timing closure have not yet been evaluated
as part of this checkpoint.

## Archive contents

- The selected placement database and SDC
- The exact Experiment B configuration
- Floorplan and placement reports
- Placement-stage logs and metrics JSON files
- SHA256SUMS for integrity verification
