# Day 13 — Floorplan Experiment C (Aspect Ratio 0.75)

## 1. Objective

Evaluate the effect of changing the floorplan aspect ratio while keeping the target core utilization and the other major implementation inputs unchanged.

Experiment C uses:

- **Platform:** Sky130HD
- **Design:** `matmul_top` (INT8 matrix-multiplication accelerator)
- **Target core utilization:** 40%
- **Core aspect ratio:** 0.75 (core height / core width)
- **Placement density:** 0.60
- **RTL:** Same INT8 matrix-multiplication RTL used for Experiment B
- **Constraints:** Same SDC used for Experiment B

Experiment B used a 1.0 aspect ratio. Therefore, the intended variable in this experiment is the core aspect ratio; utilization, RTL, SDC, platform, and placement density are held constant.

## 2. Configuration

Configuration file:

`designs/sky130hd/int8_matmul/config_expC_ar075.mk`

Relevant settings:

```makefile
export DESIGN_NICKNAME = int8_matmul_expC_ar075
export DESIGN_NAME = matmul_top
export PLATFORM = sky130hd
export VERILOG_FILES = $(sort $(wildcard /work/designs/src/int8_matmul/*.sv))
export SDC_FILE = /work/designs/sky130hd/int8_matmul/constraint.sdc
export SYNTH_HDL_FRONTEND = slang
export CORE_UTILIZATION = 40
export CORE_ASPECT_RATIO = 0.75
export PLACE_DENSITY = 0.60
export TNS_END_PERCENT = 100
```

## 3. Floorplan results

The floorplan stage completed successfully.

| Metric | Experiment C |
|---|---:|
| Die dimensions | 621.495 × 466.620 µm |
| Core bounding box | (1.380, 2.720) to (620.080, 465.120) µm |
| Core area | 286,086.880 µm² |
| Synthesized cell area | 115,132.922 µm² |
| Effective floorplan utilization | 40.2% |
| Standard-cell rows | 170 |
| Sites | 228,650 |
| Tapcells inserted | 3,784 |

The PDN grid was generated. The design contains no hard macros, so the macro-grid warning is not applicable to this design. A preliminary floorplan timing-repair report showed negative slack before placement-based parasitics were available; that result is not treated as final placement timing. The later global- and detailed-placement reports are used for the placement-stage assessment.

## 4. Global placement results

The global-placement stage completed successfully.

| Metric | Experiment C |
|---|---:|
| Placement-region utilization | 43.251% |
| Target placement density | 0.60 |
| Global-placement iterations | 628 |
| Final overflow | 0.0994 |
| Final weighted congestion | 0.7713 |
| Final global-placement HPWL | 202,958.80 µm |
| Final global-placement area | 130,830.93 µm² |
| Global-placement worst slack | +1.44233 ns |

The routability-driven placement iterations initially reported congestion above the target. Subsequent iterations reduced the weighted congestion to 0.9190, below the reported target of 1.0100, and the final weighted congestion was 0.7713.

During timing-driven placement, the resizer repaired slew/fanout/capacitance issues by resizing instances and inserting buffers. A high-fanout `clk` net before clock-tree synthesis is expected at this stage; CTS has not yet been performed for the selected floorplan.

## 5. Resizer and detailed-placement results

### 5.1 Resizer

The `do-3_4_place_resized` stage completed successfully.

| Metric | Result |
|---|---:|
| Slew violations detected by resizer | 5 |
| Instances resized | 5 |
| Buffers inserted in this stage | 0 |
| Reported design area | 127,900 µm² |
| Reported utilization | 45% |

### 5.2 Detailed placement

The `do-3_5_place_dp` stage completed successfully. The negotiation legalizer converged in phase 1 after three iterations; the violation count reduced from 3,026 initially to zero.

| Metric | Experiment C |
|---|---:|
| Core area | 286,086.88 µm² |
| Detailed-placement utilization | 44.7068% |
| Standard-cell instance area | 127,900 µm² |
| Legalizer cell moves | 6,854 |
| Legalizer average displacement | 2.2 µm |
| Legalizer maximum displacement | 17.892 µm |
| HPWL before legalization | 202,970.2 µm |
| HPWL after legalization | 221,861.0 µm |
| HPWL after placement improvement | 212,479.3 µm |
| HPWL after mirroring (final) | **212,369.5 µm** |
| Cells relocated during placement improvement | 3,029 |
| Placement violations at completion | 0 |

Legalization increased HPWL, as cells were moved to legal sites. Placement improvement then reduced the legalized HPWL by approximately 4%; mirroring made a further small improvement.

### 5.3 Detailed-placement timing and electrical checks

| Metric | Experiment C |
|---|---:|
| Setup worst slack (JSON metric) | +1.44684 ns |
| Hold worst slack (JSON metric) | +0.181645 ns |
| Setup TNS | 0 ns |
| Hold TNS | 0 ns |
| Estimated maximum frequency | 116.916 MHz |
| Setup violations | 0 |
| Hold violations | 0 |
| Maximum slew violations | 0 |
| Maximum capacitance violations | 0 |
| Maximum fanout violations | 0 |
| Flow warnings | 0 |
| Flow errors | 0 |

These are placement-stage estimates using placement parasitics. They are not post-route or signoff timing results.

The detailed-placement JSON reports estimated total power of 0.0341147 in the tool's power units (approximately 34.1 mW when interpreted as watts). Treat this as an early placement-stage estimate only; it is not final post-route power.

## 6. Experiment B versus Experiment C

Experiment B used the same target utilization and inputs but an aspect ratio of 1.0. The following comparison uses the Day 12 Experiment B detailed-placement metrics and the Day 13 Experiment C metrics.

| Metric | Experiment B (AR 1.0) | Experiment C (AR 0.75) |
|---|---:|---:|
| Target utilization | 40% | 40% |
| Actual placement utilization | 44.7613% | 44.7068% |
| Standard-cell area | 127,883 µm² | 127,900 µm² |
| Final HPWL after mirroring | 208,319.4 µm | 212,369.5 µm |
| Setup worst slack | +1.45694 ns | +1.44684 ns |
| Hold worst slack | +0.111435 ns | +0.181645 ns |
| Estimated maximum frequency | 117.054 MHz | 116.916 MHz |
| Setup/hold/electrical violations | 0 | 0 |
| Global-placement weighted congestion | 0.7877 | 0.7713 |

### Observations

1. Experiment C's final HPWL is approximately 1.94% higher than Experiment B's. Experiment B therefore has the better estimated wirelength at detailed placement.
2. Experiment B has approximately 10.1 ps more setup slack and approximately 0.138 MHz higher estimated maximum frequency. These differences are small.
3. Experiment C has approximately 70.2 ps more hold slack.
4. Experiment C's final global-placement weighted congestion is approximately 2.08% lower than Experiment B's, while its final detailed-placement HPWL is higher.
5. Both experiments have zero reported setup, hold, slew, capacitance, and fanout violations at detailed placement.
6. The standard-cell areas and actual placement utilizations are effectively the same.

### Preliminary assessment

The 0.75 aspect ratio did not produce an overall improvement over the 1.0 aspect ratio in the current placement comparison. Experiment B is slightly better in detailed-placement HPWL and setup timing; Experiment C is slightly better in hold slack and global-placement weighted congestion. Keep both candidates for the Day 14 floorplan selection rather than choosing solely on one metric.

## 7. Final placement checkpoint

The final placement checkpoint was created successfully using the `do-3_place` target.

- ODB: `results/sky130hd/int8_matmul_expC_ar075/base/3_place.odb`
- SDC: `results/sky130hd/int8_matmul_expC_ar075/base/3_place.sdc`

The final placement ODB was copied from `3_5_place_dp.odb`. The first attempt used an incorrect `DESIGN_CONFIG` path and failed with `PLATFORM variable not set`; rerunning with the correct path succeeded. No placement rerun was required after the successful copy.

## 8. Layout screenshot

**Expected screenshot path:** `screenshots/day13/expC_ar075_placement.png`

> **Screenshot pending:** Add `screenshots/day13/expC_ar075_placement.png` after capturing the OpenROAD GUI view.

Open the final placement checkpoint in the OpenROAD GUI from the ORFS `flow` directory:

```bash
util/docker_shell make gui_place \
    DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config_expC_ar075.mk
```

The ORFS `gui_place` shortcut opens the `3_place.odb` placement database. In the GUI, fit the complete core into the viewport, keep the standard-cell instances and floorplan/core boundary visible, and avoid showing routing layers as though this were a routed design. Use Windows Snipping Tool (`Win + Shift + S`) to capture the GUI, then save the PNG as:

`screenshots/day13/expC_ar075_placement.png`

The image is a visual record of placement; it does not replace the quantitative reports in this document. The screenshot is a pending local capture and is not embedded as an actual image until the PNG is saved at the path above.

## 9. Reproducibility and archived files

Relevant ORFS files:

- Configuration: `designs/sky130hd/int8_matmul/config_expC_ar075.mk`
- Floorplan report: `reports/sky130hd/int8_matmul_expC_ar075/base/2_floorplan_final.rpt`
- Global-placement report: `reports/sky130hd/int8_matmul_expC_ar075/base/3_global_place.rpt`
- Resizer report: `reports/sky130hd/int8_matmul_expC_ar075/base/3_resizer.rpt`
- Detailed-placement report: `reports/sky130hd/int8_matmul_expC_ar075/base/3_detailed_place.rpt`
- Detailed-placement metrics: `logs/sky130hd/int8_matmul_expC_ar075/base/3_5_place_dp.json`
- Final placement database: `results/sky130hd/int8_matmul_expC_ar075/base/3_place.odb`
- Final placement SDC: `results/sky130hd/int8_matmul_expC_ar075/base/3_place.sdc`

The ORFS ODB is retained in the flow results directory and is not required to be committed to the Git repository unless project storage policy requires it. Archive the configuration, reports, JSON metrics, logs, SDC, this document, and the layout screenshot in the project repository.

## 10. Day 13 conclusion

Experiment C completed synthesis, floorplanning, global placement, resizing, detailed placement, and the final placement checkpoint successfully. The detailed-placement legalizer converged with zero placement violations, and the detailed-placement timing/electrical checks reported no violations. Relative to Experiment B, Experiment C offers slightly lower global-placement weighted congestion and better hold slack, but higher detailed-placement HPWL and marginally worse setup timing. Both remain valid floorplan candidates for the Day 14 comparison.

**Scope limitation:** Clock-tree synthesis, global routing, detailed routing, extraction, and post-route timing have not been performed on this Experiment C checkpoint. The metrics in this report are pre-CTS placement-stage results.
