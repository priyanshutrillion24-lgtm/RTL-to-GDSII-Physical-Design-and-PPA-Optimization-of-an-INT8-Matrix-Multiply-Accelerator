# Day 16 — Timing-Driven Placement Experiment

## Objective

Evaluate whether increasing the maximum timing-driven net-weight multiplier improves placement timing, and measure the effects on area, estimated wirelength, placement-stage congestion, hold margin, and electrical checks.

## Experimental setup

- Platform: Sky130HD
- Design: `matmul_top` (INT8 matrix-multiplication accelerator)
- Baseline: Experiment B, `int8_matmul_expB_util40`
- Day 16 candidate: Experiment D, `int8_matmul_expD_timing_w8`
- Core utilization: 40%
- Core aspect ratio: 1.0
- Placement density: 0.60
- RTL and SDC: unchanged from Experiment B
- Timing-driven placement: enabled
- Routability-driven placement: enabled
- Changed setting: `-timing_driven_net_weight_max 8` in Experiment D (Experiment B used the OpenROAD default maximum weight of 5)

The Experiment D global-placement log confirms that the command included:

```text
global_placement ... -routability_driven -timing_driven ... -timing_driven_net_weight_max 8
```

## Results: Experiment B vs Experiment D

| Metric | Experiment B (weight 5) | Experiment D (weight 8) |
|---|---:|---:|
| Core area (µm²) | 285,699 | 285,699 |
| Detailed-placement cell area (µm²) | 127,883 | 127,846 |
| Detailed-placement utilization | 44.7613% | 44.7486% |
| Setup worst slack (ns) | **+1.45694** | +1.36651 |
| Hold worst slack (ns) | +0.111435 | **+0.428816** |
| Estimated Fmax (MHz) | **117.054** | 115.828 |
| Global-placement estimated HPWL (µm) | 197,820 | 209,634.17 |
| Detailed-placement final HPWL (µm) | **208,319.4** | 216,734.2 |
| Final weighted placement congestion | **0.787743** | 0.810605 |
| Setup violations | 0 | 0 |
| Hold violations | 0 | 0 |
| Maximum-slew violations | **0** | 23 |
| Maximum-fanout violations | 0 | 0 |
| Maximum-capacitance violations | 0 | 0 |
| Detailed-placement legality violations | 0 | 0 |

Notes:

- HPWL is half-perimeter wirelength, an estimated placement wirelength metric; it is not routed wirelength.
- The weighted congestion values are placement-stage routability estimates; they are not global-route or detailed-route congestion results.
- Fmax is the estimate reported by the detailed-placement timing analysis, not a post-route or signoff frequency.
- Both candidates have zero setup and hold violation counts at detailed placement. Experiment D nevertheless has 23 reported maximum-slew violations.

## Critical-path comparison

Both reports identify a synchronous maximum-delay path in the `core_clk` path group.

| Detail | Experiment B | Experiment D |
|---|---|---|
| Startpoint | `u_controller.k_idx[0]$_DFF_PN0_` | `u_controller.k_idx[0]$_DFF_PN0_` |
| Endpoint | `u_mac_array.gen_mac[0].u_mac.acc_value[18]$_DFFE_PN0P_` | `u_mac_array.gen_mac[0].u_mac.acc_value[13]$_DFFE_PN0P_` |
| Data arrival (ns) | 8.24 | 8.33 |
| Data required (ns) | 9.70 | 9.70 |
| Slack (ns) | **1.46** | 1.37 |

The common path function is controller `k_idx` register → mux and control logic → full-adder/half-adder carry chain and following logic → MAC accumulator register. The endpoint bit differs, but the path remains in the controller-to-MAC accumulation datapath.

Experiment D's listed path has an additional mux stage relative to the displayed Experiment B path and different buffering/gating. The observed data-arrival increase is approximately 0.09 ns. These report differences are observations; they do not by themselves establish the detailed causal effect of the weighting option on each cell.

## Interpretation and decision

Increasing the timing-driven net-weight maximum from 5 to 8 did not improve the overall placement result:

- Setup slack decreased by about 0.090 ns.
- Estimated Fmax decreased by about 1.226 MHz.
- Detailed-placement HPWL increased by about 4.04%.
- Weighted placement congestion increased by about 2.90%.
- Maximum-slew violations increased from zero to 23.
- Cell area was effectively unchanged (Experiment D was 37 µm² smaller).
- Hold slack improved, but both candidates already had zero hold violations.

**Decision: retain Experiment B (40% utilization, aspect ratio 1.0, default timing-driven maximum weight) as the preferred placement candidate.** Experiment D is retained as a documented comparison, not selected as the new baseline.

## Artifacts

Experiment D configuration:

```text
designs/sky130hd/int8_matmul/config_expD_timing_w8.mk
```

Experiment D run directories:

```text
results/sky130hd/int8_matmul_expD_timing_w8/base/
reports/sky130hd/int8_matmul_expD_timing_w8/base/
logs/sky130hd/int8_matmul_expD_timing_w8/base/
```

Key reports and logs:

```text
reports/sky130hd/int8_matmul_expD_timing_w8/base/3_detailed_place.rpt
logs/sky130hd/int8_matmul_expD_timing_w8/base/3_3_place_gp.log
logs/sky130hd/int8_matmul_expD_timing_w8/base/3_3_place_gp.json
logs/sky130hd/int8_matmul_expD_timing_w8/base/3_5_place_dp.json
results/sky130hd/int8_matmul_expD_timing_w8/base/3_place.odb
results/sky130hd/int8_matmul_expD_timing_w8/base/3_place.sdc
```

## Scope and limitations

This is a placement-stage comparison. No conclusion is made about CTS, routed parasitics, post-route timing, or signoff. The next roadmap stage is to continue with the planned placement work and then proceed to CTS on the selected candidate when the schedule reaches that stage.
