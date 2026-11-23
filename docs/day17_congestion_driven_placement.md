# Day 17 — Congestion-Driven Placement Experiment

**Project:** INT8 Matrix-Multiplication Accelerator — RTL-to-GDSII / PPA Optimization
**Platform:** Sky130HD
**Design top:** `matmul_top`
**Documentation date:** 23 November 2026

## 1. Objective

Evaluate a routability-focused placement configuration using FastRoute-based congestion estimation, inspect the resulting congestion and electrical metrics, and compare the outcome with the previously selected timing-driven placement candidate.

The selected placement checkpoint before Day 17 was **Experiment B** (40% target core utilization, aspect ratio 1.0). Experiment D was the Day 16 timing-driven weighting experiment.

## 2. Experimental setup

### 2.1 Experiment E — FastRoute with timing-driven placement enabled

Configuration used:

```make
export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.60
export GPL_ROUTABILITY_DRIVEN = 1
export GPL_TIMING_DRIVEN = 1
export GLOBAL_PLACEMENT_ARGS = -routability_use_grt
```

FastRoute congestion estimates during the routability loop were:

| Iteration | Final routing congestion |
|---|---:|
| 1 | 1.0447441 |
| 2 | 1.0296949 |
| 3 | 1.0012195 |

At iteration 3, the reported horizontal overflow was 0.0000, vertical overflow was 0.0667, and one overflow tile remained. The run reported that the routing-congestion target of 1.0100 had been achieved. However, after routability optimization, global placement entered timing-driven iteration 2/2 and terminated with `Signal 8 received` (SIGFPE) before the overall placement stage completed.

**Status:** Experiment E is an incomplete run. Its intermediate FastRoute congestion observations are retained for troubleshooting, but it has no valid final global-placement or detailed-placement checkpoint and is not used in the final placement comparison.

### 2.2 Experiment F — FastRoute congestion-focused placement

Experiment F was created from the Experiment B configuration, with a unique design nickname and the following placement settings:

```make
export DESIGN_NICKNAME = int8_matmul_expF_grt_congestion_only
export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.60
export GPL_ROUTABILITY_DRIVEN = 1
export GPL_TIMING_DRIVEN = 0
export GLOBAL_PLACEMENT_ARGS = -routability_use_grt
```

The RTL, SDC, platform, target utilization, and placement density were retained from the Experiment B setup. Timing-driven placement was disabled to avoid the timing-driven pass where Experiment E had terminated. Experiment F therefore changes both the congestion-estimation approach (FastRoute instead of the earlier default RUDY estimate) and the timing-driven placement setting; it is a congestion-focused variant, not a one-variable controlled comparison against B.

**Run status:** Global placement, placement resizing, and detailed placement all completed. The final placement database `3_place.odb` and SDC `3_place.sdc` were generated. The corresponding placement-stage flow logs report zero flow errors.

## 3. Experiment F — FastRoute congestion observations

The FastRoute-based routability loop produced the following results:

| Iteration | Horizontal overflow | Vertical overflow | Final routing congestion |
|---|---:|---:|---:|
| 1 | 0.4000 | 0.7845 | 1.0164210 |
| 2 | 1.0227 | 0.6500 | 1.0219156 |
| 3 | 0.2000 | 1.2690 | 1.0250470 |
| 4 | 0.2000 | 1.1833 | 1.0222812 |

The configured routing-congestion target was 1.0100. The best observed value was 1.0164210, so the target was **not reached**. The log states that the routability optimizer reverted to the minimally observed congestion result and completed its search. Global placement finished at iteration 763; the routability iteration count was 376.

The FastRoute `Final routing congestion` values above are distinct from the global placer's own weighted routability metric. They must not be treated as numerically interchangeable with the RUDY weighted congestion values recorded for Experiments B and D.

## 4. Experiment F — placement results

### 4.1 Global placement

| Metric | Result |
|---|---:|
| Global-placement iterations | 763 |
| Routability iterations | 376 |
| Global-placement area reported by placer (final) | 137,362 µm² |
| Estimated route wirelength metric | 204,301 µm |
| Core area | 285,699 µm² |
| Die area | 289,982 µm² |
| Global-placement flow errors | 0 |

The global-placement JSON also contains a globalplacer congestion metric of 0.800983. This is a separate tool metric and is not compared directly with the FastRoute `Final routing congestion` values or the RUDY-weighted values from B and D.

### 4.2 Resizer / placement optimization

The resizer log reports that it initially found 612 slew violations, 17 fanout violations, and 4 capacitance violations. It resized 746 instances and inserted 716 buffers across 577 nets.

After this repair stage, the resizer JSON reported:

| Metric | After resizing |
|---|---:|
| Maximum-slew violations | 11 |
| Maximum-capacitance violations | 0 |
| Maximum-fanout violations | 0 |
| Setup violations | 0 |
| Hold violations | 0 |
| Setup worst slack | +0.823423 ns |
| Hold worst slack | +0.424914 ns |
| Estimated Fmax | 108.973 MHz |
| Standard-cell instance area | 130,790 µm² |

### 4.3 Detailed placement

| Metric | Result |
|---|---:|
| Detailed-placement standard-cell area | 130,790 µm² |
| Actual detailed-placement utilization | 45.7791% |
| Final HPWL after placement improvement and mirroring | 260,943.6 µm |
| Estimated route wirelength metric | 270,868 µm |
| Setup worst slack | +0.857670 ns |
| Hold worst slack | +0.428766 ns |
| Setup TNS | 0 ns |
| Hold TNS | 0 ns |
| Estimated Fmax | 109.381 MHz |
| Placement legality violations | 0 |
| Setup violations | 0 |
| Hold violations | 0 |
| Maximum-slew violations | 267 |
| Maximum-capacitance violations | 0 |
| Maximum-fanout violations | 0 |
| Detailed-placement flow errors | 0 |

HPWL is an estimated placement interconnect metric, not routed wirelength. The route-wirelength metric is reported separately and must not be substituted for HPWL.

## 5. Investigation of maximum-slew violations

Although the resizer reduced maximum-slew violations from 612 initially to 11 after repair, the detailed-placement report subsequently reported 267 maximum-slew violating pins. This increase occurred between the resizer and detailed-placement metric snapshots. The available reports do not establish the exact physical cause of the increase, so no single cell movement or net is identified as the proven cause.

The detailed-placement violator list includes pins associated with:

- `u_storage.matrix_a[...]`
- `u_storage.matrix_b[...]`
- `u_storage.result_mem[...]`
- Automatically named buffer instances such as `fanout664`, `fanout694`, and others.

The reported maximum transition limit is 0.50, with listed violating slew values extending approximately from 0.51 to 0.57. The final detailed-placement report records a worst maximum-slew-check slack of approximately -0.06508. Maximum-capacitance and maximum-fanout violation counts are zero.

This shows that the remaining electrical issue is specifically associated with maximum transition/slew checks. The listed pins suggest that storage-related input and buffer networks deserve further investigation, but the report alone does not map every listed pin to its complete RTL source net.

## 6. Comparison with the selected and timing-driven placements

The following table compares detailed-placement results. Experiment B is the selected baseline, Experiment D is the Day 16 timing-driven weighting experiment, and Experiment F is the Day 17 congestion-focused experiment.

| Metric | Experiment B | Experiment D | Experiment F |
|---|---:|---:|---:|
| Timing-driven placement | Enabled | Enabled | Disabled |
| Congestion estimation | Default RUDY | Default RUDY | FastRoute-based |
| Target core utilization | 40% | 40% | 40% |
| Detailed-placement cell area (µm²) | 127,883 | 127,846 | 130,790 |
| Actual detailed-placement utilization | 44.7613% | 44.7486% | 45.7791% |
| Final detailed-placement HPWL (µm) | **208,319.4** | 216,734.2 | 260,943.6 |
| Setup worst slack (ns) | **+1.45694** | +1.36651 | +0.857670 |
| Hold worst slack (ns) | +0.111435 | +0.428816 | +0.428766 |
| Estimated Fmax (MHz) | **117.054** | 115.828 | 109.381 |
| Setup / hold violations | 0 / 0 | 0 / 0 | 0 / 0 |
| Maximum-slew violations | **0** | 23 | 267 |
| Maximum-capacitance violations | 0 | 0 | 0 |
| Maximum-fanout violations | 0 | 0 | 0 |
| Placement legality violations | 0 | 0 | 0 |

**Comparison caveat:** The congestion metrics from B/D and F are generated using different estimation approaches. The FastRoute routing-congestion result for F is therefore discussed separately rather than compared as if it were the same metric as the RUDY weighted congestion scores.

## 7. Interpretation and decision

1. Experiment F completed global placement, resizing, and detailed placement without a flow error.
2. The FastRoute routability loop did not meet the target congestion of 1.0100; its best observed `Final routing congestion` was 1.0164210.
3. Disabling timing-driven placement avoided the timing-driven pass that had terminated Experiment E, but Experiment F's final placement timing was worse than B and D.
4. Experiment F has a larger detailed-placement HPWL and higher standard-cell area than B.
5. Resizer repair substantially reduced initial slew violations, but the final detailed-placement metrics report 267 maximum-slew violations.
6. Experiment F has positive setup and hold slack and zero setup/hold violations, but its electrical and placement-quality results are inferior to the selected B candidate.

**Decision: retain Experiment B as the selected placement candidate.** Experiment F is retained as a documented congestion-focused experiment, not selected as the checkpoint for subsequent implementation stages. Experiment E is retained as an incomplete FastRoute/timing-driven attempt and is not treated as a completed result.

## 8. Scope and limitations

These results are pre-CTS placement-stage measurements. Clock-tree synthesis, detailed routing, extracted parasitic timing, post-route STA, and signoff physical verification have not been completed for these Day 17 experiments. The reported Fmax and timing values are placement-stage estimates, not post-route or signoff operating-frequency claims. HPWL and estimated route-wirelength metrics are not actual detailed-routed wirelength.

## 9. Reproducibility and artifacts

Experiment F configuration:

```text
designs/sky130hd/int8_matmul/config_expF_grt_congestion_only.mk
```

Experiment F results:

```text
results/sky130hd/int8_matmul_expF_grt_congestion_only/base/
```

Experiment F logs:

```text
logs/sky130hd/int8_matmul_expF_grt_congestion_only/base/
```

Experiment F reports:

```text
reports/sky130hd/int8_matmul_expF_grt_congestion_only/base/
```

Key files include:

```text
logs/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_3_place_gp.log
logs/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_3_place_gp.json
logs/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_4_place_resized.log
logs/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_4_place_resized.json
logs/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_5_place_dp.log
logs/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_5_place_dp.json
reports/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_resizer.rpt
reports/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_detailed_place.rpt
results/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_place.odb
results/sky130hd/int8_matmul_expF_grt_congestion_only/base/3_place.sdc
```

The experiment configuration, this report, selected logs/JSON metrics/reports, and any relevant screenshots should be version-controlled. Large generated databases and temporary flow outputs should follow the repository's existing tracking policy.
