# Day 14 — Floorplan Selection

## 1. Objective

Compare floorplan Experiments A, B and C using measured area, utilization, HPWL, placement-stage timing, congestion and electrical checks. Select one configuration to carry forward and record the trade-offs.

All timing and electrical values below are from the detailed-placement stage. Congestion values are from global placement. These are pre-CTS placement estimates, not post-route or signoff results.

## 2. Consolidated comparison

| Metric | A: 30%, AR 1.0 | B: 40%, AR 1.0 | C: 40%, AR 0.75 |
|---|---:|---:|---:|
| Core area (µm²) | 382,010 | 285,699 | 286,087 |
| Standard-cell area (µm²) | 129,388 | 127,883 | 127,900 |
| Actual placement utilization | 33.87% | 44.76% | 44.71% |
| Final detailed-placement HPWL (µm) | **206,064.0** | 208,319.4 | 212,369.5 |
| Setup worst slack (ns) | +1.41973 | **+1.45694** | +1.44684 |
| Hold worst slack (ns) | **+0.471308** | +0.111435 | +0.181645 |
| Estimated Fmax (MHz) | 116.546 | **117.054** | 116.916 |
| Global-placement weighted congestion | 0.7734 | 0.7877 | **0.7713** |
| Max slew violations | 16 | **0** | **0** |
| Max fanout violations | 0 | 0 | 0 |
| Max capacitance violations | 0 | 0 | 0 |

## 3. Experiment observations

### Experiment A — 30% utilization, square floorplan

Experiment A has the lowest final detailed-placement HPWL (206,064 µm) and the largest positive hold slack (+0.471308 ns). Its core area is significantly larger than B and C, and the detailed-placement metrics report 16 maximum-slew violations. It therefore provides more placement space but is not as electrically clean at this checkpoint.

### Experiment B — 40% utilization, aspect ratio 1.0

Experiment B has the smallest core area (285,699 µm²) and standard-cell area (127,883 µm²), the best setup slack (+1.45694 ns), and the highest estimated Fmax (117.054 MHz). It reports zero slew, fanout and capacitance violations. Its hold slack is lower than A and C, but remains positive (+0.111435 ns). Its weighted congestion (0.7877) is slightly higher than A and C, while remaining below the reported routability target of 1.0100.

### Experiment C — 40% utilization, aspect ratio 0.75

Experiment C has the lowest weighted congestion (0.7713) and zero reported electrical violations. However, its final HPWL (212,369.5 µm) is the highest of the three, and its setup slack and estimated Fmax are slightly below B. The aspect-ratio change did not produce an overall improvement over B in these placement-stage results.

## 4. Selected floorplan

**Recommended selection: Experiment B — 40% target utilization, aspect ratio 1.0.**

Rationale:

1. It has the smallest core area and standard-cell area among the candidates.
2. It provides the best setup slack and estimated maximum frequency.
3. It has zero reported maximum-slew, maximum-fanout and maximum-capacitance violations at detailed placement.
4. Its HPWL is only about 1.1% higher than A, while it has a smaller core and cleaner electrical checks.
5. Its weighted congestion is marginally higher than A and C, but all three candidates achieved low final weighted-congestion values (0.7713–0.7877) below the reported 1.0100 routability target.

Experiment B is therefore the best overall balance for carrying forward. This is a placement-stage selection; CTS, routing, extraction and post-route STA may change the final ranking.

## 5. Configuration to carry forward

- Experiment: B
- ORFS configuration: `designs/sky130hd/int8_matmul/config_expB_util40.mk`
- Platform: Sky130HD
- Target core utilization: 40%
- Aspect ratio: 1.0 (square floorplan)
- Placement density: 0.60
- RTL and SDC: unchanged from the baseline experiment

Preserve Experiments A, B and C as separate records. Do not overwrite their configurations or result databases.

## 6. Scope and limitations

- Timing and electrical checks are placement-stage results with placement parasitics.
- Weighted congestion is the global-placement estimate; it is not a detailed-route DRC result.
- Clock-tree synthesis has not been run on the selected Experiment B floorplan as the final project CTS checkpoint.
- No post-route timing, extracted parasitics or signoff DRC/LVS conclusion is made here.

## 7. Day 14 completion checklist

- [ ] Preserve the configuration files for A, B and C.
- [ ] Archive the corresponding reports, JSON metrics and logs.
- [ ] Add the Experiment C layout screenshot when available.
- [ ] Commit this decision report and comparison data to Git.
- [ ] Carry Experiment B forward as the selected floorplan for the next project phase.
