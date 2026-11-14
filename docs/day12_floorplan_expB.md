# Day 12 – Floorplan Experiment B: 40% Utilization

**Project:** INT8 Matrix Multiplication Accelerator
**Technology:** Sky130HD
**Tool:** OpenROAD-flow-scripts
**Experiment:** B – Increased core utilization

## 1. Objective

Evaluate the effect of increasing target core utilization from 30% to 40%.

The objective is to observe changes in core area, placement behavior, wirelength, congestion and timing while keeping the RTL, timing constraints and placement density unchanged.

## 2. Experiment Configuration

| Parameter | Value |
|---|---|
| Design | matmul_top |
| Platform | Sky130HD |
| Target core utilization | 40% |
| Placement density | 0.60 |
| Clock period | 10 ns |
| RTL | Same as Experiment A |
| SDC | Same as Experiment A |

## 3. Floorplan Results

| Metric | Experiment B |
|---|---:|
| Die dimensions | 538.5 × 538.5 µm |
| Core area | 285,699.008 µm² |
| Synthesis cell area | 115,132.92 µm² |
| Detailed-placement cell area | 127,883 µm² |
| Detailed-placement utilization | 44.7613% |

## 4. Placement Results

### Global Placement

| Metric | Result |
|---|---:|
| Global placement setup slack | +1.44 ns |
| Global placement TNS | 0 ns |
| Final weighted routing congestion | 0.7877 |
| Final HPWL | 197,820.26 µm |

### Detailed Placement

| Metric | Result |
|---|---:|
| Negotiation legalization iterations | 4 |
| Total cell moves | 6,893 |
| Average displacement | 2.221 µm |
| Maximum displacement | 16.537 µm |
| HPWL before legalization | 197,823.7 µm |
| HPWL after legalization | 217,169.0 µm |
| HPWL after improvement | 208,520.1 µm |
| Final HPWL after mirroring | 208,319.4 µm |

Placement legalization converged with zero remaining placement violations.

## 5. Final Timing and Electrical Checks

| Metric | Result |
|---|---:|
| Setup worst slack | +1.45694 ns |
| Hold worst slack | +0.111435 ns |
| Setup TNS | 0 ns |
| Hold TNS | 0 ns |
| Minimum clock period | 8.54 ns |
| Estimated maximum frequency | 117.054 MHz |
| Maximum slew violations | 0 |
| Maximum fanout violations | 0 |
| Maximum capacitance violations | 0 |
| Placement design violations | 0 |

No flow warnings or errors were recorded in the final detailed-placement JSON metrics.

## 6. Comparison with Experiment A

| Metric | Experiment A: 30% | Experiment B: 40% |
|---|---:|---:|
| Core area (µm²) | 382,010 | 285,699 |
| Placement cell area (µm²) | 129,388 | 127,883 |
| Final utilization | 33.87% | 44.76% |
| Detailed-placement HPWL (µm) | 206,064 | 208,319 |
| Setup slack (ns) | +1.42 | +1.457 |
| Hold slack (ns) | +0.471 | +0.111 |

## 7. Observations

1. Increasing target utilization from 30% to 40% reduced core area by approximately 25.21%.
2. Detailed-placement HPWL increased by approximately 1.09%.
3. Setup slack improved slightly.
4. Hold slack decreased substantially, although it remained positive.
5. No maximum slew, maximum fanout or maximum capacitance violations were reported after detailed placement.
6. The placement engine achieved a final weighted congestion metric of 0.7877.

The result demonstrates an area-versus-wirelength and setup-versus-hold trade-off.

The global-placement congestion value is an estimated routing-demand metric and does not represent completed global routing.

## 8. Conclusion

Experiment B successfully completed synthesis, floorplanning, global placement, resizing and detailed placement.

The 40% utilization configuration achieved a smaller core and slightly better setup slack than the 30% baseline, but with increased estimated wirelength and a narrower hold margin.

Experiment B will be retained as the second floorplan candidate. No final floorplan selection is made yet.

**Next:** Day 13 – Floorplan Experiment C, changing aspect ratio and/or I/O pin placement.
