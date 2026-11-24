# Day 18 — Placement Optimization

**Project:** INT8 Matrix-Multiplication Accelerator — RTL-to-GDSII / PPA Optimization
**Platform:** Sky130HD
**Design top:** `matmul_top`
**Date:** 24 November 2026
**Flow:** OpenROAD-flow-scripts (ORFS), Yosys, OpenROAD
**Placement checkpoint used as reference:** Experiment B (`int8_matmul_expB_util40`)

## 1. Objective

Evaluate the effect of changing the target placement density while keeping the design, floorplan, timing constraints, platform, and other configuration settings unchanged. The objective is to identify whether a modest density change improves the overall placement trade-off among congestion, estimated wirelength, timing, cell area, and electrical checks.

The Day 18 experiments are:

- **Experiment B:** reference placement, `PLACE_DENSITY = 0.60`.
- **Experiment G:** lower-density experiment, `PLACE_DENSITY = 0.55`.
- **Experiment H:** higher-density experiment, `PLACE_DENSITY = 0.65`.

Experiments G and H were created by copying Experiment B's configuration and changing only the design nickname and `PLACE_DENSITY` value. The baseline configuration and results were not overwritten.

## 2. Common configuration

The following settings were common to B, G, and H:

```make
export DESIGN_NAME = matmul_top
export PLATFORM = sky130hd
export VERILOG_FILES = $(sort $(wildcard /work/designs/src/int8_matmul/*.sv))
export SDC_FILE = /work/designs/sky130hd/int8_matmul/constraint.sdc
export SYNTH_HDL_FRONTEND = slang
export CORE_UTILIZATION = 40
export TNS_END_PERCENT = 100
```

The three configurations used the same ORFS placement flow settings inherited from the Experiment B configuration. No RTL, SDC, floorplan aspect-ratio, or placement-flow option was intentionally changed for G or H.

## 3. Experiment configurations

### 3.1 Experiment B — reference

Configuration: `designs/sky130hd/int8_matmul/config_expB_util40.mk`

```make
export DESIGN_NICKNAME = int8_matmul_expB_util40
export DESIGN_NAME = matmul_top
export PLATFORM = sky130hd
export VERILOG_FILES = $(sort $(wildcard /work/designs/src/int8_matmul/*.sv))
export SDC_FILE = /work/designs/sky130hd/int8_matmul/constraint.sdc
export SYNTH_HDL_FRONTEND = slang
export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.60
export TNS_END_PERCENT = 100
```

Experiment B is the selected reference placement from the earlier floorplan/placement comparison. Its core aspect ratio is 1.0 and its core area is approximately 285,699 µm².

### 3.2 Experiment G — lower placement density

Configuration: `designs/sky130hd/int8_matmul/config_expG_density055.mk`

```make
export DESIGN_NICKNAME = int8_matmul_expG_density055
export DESIGN_NAME = matmul_top
export PLATFORM = sky130hd
export VERILOG_FILES = $(sort $(wildcard /work/designs/src/int8_matmul/*.sv))
export SDC_FILE = /work/designs/sky130hd/int8_matmul/constraint.sdc
export SYNTH_HDL_FRONTEND = slang
export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.55
export TNS_END_PERCENT = 100
```

**Single functional change relative to B:** target placement density reduced from 0.60 to 0.55.

### 3.3 Experiment H — higher placement density

Configuration: `designs/sky130hd/int8_matmul/config_expH_density065.mk`

```make
export DESIGN_NICKNAME = int8_matmul_expH_density065
export DESIGN_NAME = matmul_top
export PLATFORM = sky130hd
export VERILOG_FILES = $(sort $(wildcard /work/designs/src/int8_matmul/*.sv))
export SDC_FILE = /work/designs/sky130hd/int8_matmul/constraint.sdc
export SYNTH_HDL_FRONTEND = slang
export CORE_UTILIZATION = 40
export PLACE_DENSITY = 0.65
export TNS_END_PERCENT = 100
```

**Single functional change relative to B:** target placement density increased from 0.60 to 0.65.

## 4. Run commands

Experiment G:

```bash
cd ~/eda/OpenROAD-flow-scripts/flow
util/docker_shell make place \
  DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config_expG_density055.mk
```

Experiment H:

```bash
cd ~/eda/OpenROAD-flow-scripts/flow
util/docker_shell make place \
  DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config_expH_density065.mk
```

Both experiments completed global placement, resizing, detailed placement, and generated the final placement database (`3_place.odb`).

## 5. Measured results

All timing, utilization, area, HPWL, and electrical-check figures below are placement-stage results. They are not post-CTS, post-route, extracted-parasitic, or signoff results.

### 5.1 Global-placement comparison

| Metric | Experiment B (0.60) | Experiment G (0.55) | Experiment H (0.65) |
|---|---:|---:|---:|
| Final weighted placement congestion | 0.787743 | **0.700949** | 0.833087 |
| Estimated global-placement route wirelength (µm) | 197,820 | 205,203 | **189,979** |
| Global-placement setup worst slack (ns) | — | +1.20957 | +1.38914 |
| Global-placement hold worst slack (ns) | — | +0.115968 | +0.433924 |
| Global-placement estimated Fmax (MHz) | 116.834 | 113.760 | 116.132 |
| Final global-placement area (µm²) | 130,745 | 129,656 | 130,811 |
| Global-placement flow errors | 0 | 0 | 0 |

**Metric note:** `globalplace__route__wirelength__estimated` is reported as an estimated route-wirelength metric. It is not labelled as the detailed-placement final HPWL. The dash for B means the corresponding stage-specific timing values were not carried into this comparison table; B's detailed-placement timing values are shown below.

### 5.2 Detailed-placement comparison

| Metric | Experiment B (0.60) | Experiment G (0.55) | Experiment H (0.65) |
|---|---:|---:|---:|
| Standard-cell instance area (µm²) | 127,883 | 127,814 | **127,811** |
| Actual detailed-placement utilization | 44.7613% | 44.7372% | 44.7364% |
| Final detailed-placement HPWL (µm) | 208,319.4 | 214,079.5 | **202,801.5** |
| Estimated detailed-placement route wirelength (µm) | 217,169 | 222,724 | **211,731** |
| Setup worst slack (ns) | **+1.45694** | +1.36023 | +1.42477 |
| Hold worst slack (ns) | +0.111435 | +0.120266 | **+0.424804** |
| Estimated Fmax (MHz) | **117.054** | 115.744 | 116.615 |
| Setup TNS (ns) | 0 | 0 | 0 |
| Hold TNS (ns) | 0 | 0 | 0 |
| Setup violations | 0 | 0 | 0 |
| Hold violations | 0 | 0 | 0 |
| Maximum-slew violations | **0** | 4 | 10 |
| Maximum-capacitance violations | 0 | 0 | 0 |
| Maximum-fanout violations | 0 | 0 | 0 |
| Detailed-placement legality/design violations | 0 | 0 | 0 |
| Detailed-placement flow errors | 0 | 0 | 0 |

**Metric note:** HPWL (half-perimeter wirelength) and the ORFS estimated route-wirelength metric are distinct metrics. They are intentionally shown in separate rows and should not be interchanged.

## 6. Analysis of the density experiments

### 6.1 Lower density: Experiment G (0.55)

Relative to B:

- Weighted placement congestion decreased from 0.787743 to 0.700949, an improvement of approximately **11.02%**.
- Detailed-placement HPWL increased from 208,319.4 µm to 214,079.5 µm, approximately **2.77% higher**.
- Estimated detailed-placement route wirelength increased by approximately **2.56%**.
- Setup slack decreased by approximately 96.71 ps.
- Estimated Fmax decreased from 117.054 MHz to 115.744 MHz.
- Four maximum-slew violations were reported, compared with zero for B.

**Interpretation:** Reducing target density produced a lower weighted congestion estimate, but this came with higher estimated wirelength, worse setup timing, and four slew violations. G is not a better overall candidate than B.

### 6.2 Higher density: Experiment H (0.65)

Relative to B:

- Weighted placement congestion increased from 0.787743 to 0.833087, approximately **5.76% higher**.
- Detailed-placement HPWL decreased from 208,319.4 µm to 202,801.5 µm, approximately **2.65% lower**.
- Estimated detailed-placement route wirelength decreased by approximately **2.50%**.
- Setup slack decreased by approximately 32.17 ps.
- Estimated Fmax decreased from 117.054 MHz to 116.615 MHz.
- Hold slack improved by approximately 313.37 ps.
- Ten maximum-slew violations were reported, compared with zero for B.

**Interpretation:** Increasing target density improved estimated wirelength and hold margin, but increased the weighted congestion estimate and produced ten maximum-slew violations. Setup timing and estimated Fmax were slightly worse than B.

### 6.3 Overall comparison

The experiments demonstrate a trade-off rather than a monotonic improvement:

- Lower density (G) gave the best weighted congestion estimate.
- Higher density (H) gave the lowest detailed-placement HPWL and estimated route wirelength.
- Baseline density (B) gave the best setup slack and estimated Fmax, and it was the only candidate among these three with zero reported maximum-slew violations.

The small cell-area differences among B, G, and H are not decisive by themselves. The timing and electrical checks are more important to the selection decision for this stage.

## 7. Selection rationale

**Selected placement candidate: Experiment B (`int8_matmul_expB_util40`, `PLACE_DENSITY = 0.60`).**

Experiment B remains the preferred placement because it offers the best overall balance across the measured objectives:

1. Highest detailed-placement setup slack: +1.45694 ns.
2. Highest estimated detailed-placement Fmax: 117.054 MHz.
3. Zero maximum-slew, maximum-capacitance, maximum-fanout, setup, hold, and placement legality violations.
4. Lower detailed-placement HPWL than G, while avoiding H's higher congestion estimate and slew violations.

G and H remain useful documented experiments. Neither should replace B as the selected placement checkpoint based on the current placement-stage evidence.

## 8. Limitations and interpretation notes

- These are pre-CTS placement-stage measurements using placement parasitics. They do not establish post-CTS or post-route timing, routed wirelength, or signoff quality.
- Weighted congestion is a global-placer estimate, not a detailed-routing DRC or overflow result.
- HPWL and estimated route wirelength are different reported quantities.
- The results compare one design and one placement flow configuration. They do not establish that 0.60 is universally optimal for other designs or floorplans.
- The measured maximum-slew counts are reported by the detailed-placement metrics. A nonzero count should be treated as an electrical issue even when setup/hold and placement legality violations are zero.

## 9. Artifacts and result directories

Experiment B:

```text
designs/sky130hd/int8_matmul/config_expB_util40.mk
results/sky130hd/int8_matmul_expB_util40/base/3_place.odb
logs/sky130hd/int8_matmul_expB_util40/base/
reports/sky130hd/int8_matmul_expB_util40/base/
```

Experiment G:

```text
designs/sky130hd/int8_matmul/config_expG_density055.mk
results/sky130hd/int8_matmul_expG_density055/base/3_place.odb
logs/sky130hd/int8_matmul_expG_density055/base/3_3_place_gp.json
logs/sky130hd/int8_matmul_expG_density055/base/3_5_place_dp.json
reports/sky130hd/int8_matmul_expG_density055/base/
```

Experiment H:

```text
designs/sky130hd/int8_matmul/config_expH_density065.mk
results/sky130hd/int8_matmul_expH_density065/base/3_place.odb
logs/sky130hd/int8_matmul_expH_density065/base/3_3_place_gp.json
logs/sky130hd/int8_matmul_expH_density065/base/3_5_place_dp.json
reports/sky130hd/int8_matmul_expH_density065/base/
```

## 10. Day 18 conclusion and handoff

The Day 18 placement-density study is complete. Two controlled density changes were measured against the unchanged Experiment B reference. Experiment G improved weighted congestion but worsened estimated wirelength and timing. Experiment H improved HPWL and hold margin but worsened weighted congestion and had ten maximum-slew violations.

**Experiment B remains the selected placement candidate for the Day 19 placement checkpoint.** The next step is to freeze its configuration and archive the selected placement database, SDC, reports, JSON metrics, and relevant logs before proceeding to clock-tree synthesis preparation.
