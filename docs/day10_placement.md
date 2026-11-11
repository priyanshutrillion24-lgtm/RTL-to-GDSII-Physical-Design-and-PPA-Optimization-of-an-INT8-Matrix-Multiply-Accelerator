# Day 10 – Global Placement, Resizing and Detailed Placement

## 1. Objective

The objective of Day 10 was to perform standard-cell placement for the INT8 matrix multiplication accelerator using the OpenROAD physical design flow.

The activities included:

- Initial global placement.
- I/O pin placement.
- Timing-driven and routability-driven global placement.
- Placement resizing and buffering.
- Detailed placement and legalization.
- Post-placement timing analysis.

The input to the placement flow was the floorplan database generated during Day 9.

## 2. Placement Configuration

| Parameter | Value |
|---|---|
| Platform | Sky130HD |
| Design | matmul_top |
| Core utilization target | 30% |
| Placement density target | 0.60 |
| Clock period | 10 ns |
| Target frequency | 100 MHz |
| Input database | 2_floorplan.odb |

The placement flow was executed using OpenROAD-flow-scripts.

## 3. Stage 3_1 – Initial Global Placement

Command:

```bash
util/docker_shell make do-3_1_place_gp_skip_io \
    DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config.mk
```

Global placement was performed without considering placed I/O pins.

### Initial placement statistics

| Parameter | Result |
|---|---:|
| Total instances | 11,079 |
| Movable instances | 6,041 |
| Fixed instances | 5,038 |
| Number of nets | 7,095 |
| Number of pins | 25,515 |
| Core area | 382,010.128 µm² |
| Placement target density | 0.60 |
| Reported utilization | 32.484% |

The 5,038 fixed instances correspond to the tap cells inserted during floorplanning. The global placer operated on the 6,041 movable instances.

### Global placement results

- Placement iterations: 401
- Final overflow: 0.0998
- Final HPWL: 200,920.42 µm

HPWL (Half-Perimeter Wirelength) is an estimate of total interconnect length based on the bounding boxes of nets.

The placement engine distributed the standard cells across the core while reducing placement overflow.

Output database:

`3_1_place_gp_skip_io.odb`

## 4. Stage 3_2 – I/O Pin Placement

Command:

```bash
util/docker_shell make do-3_2_place_iop \
    DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config.mk
```

I/O pins were assigned physical locations along the chip boundary.

### I/O placement results

| Parameter | Result |
|---|---:|
| Available I/O slots | 2,254 |
| Total I/O pins | 47 |
| I/O pins with sinks | 47 |
| I/O pins without sinks | 0 |
| Minimum pin spacing | 2 tracks |
| I/O net HPWL | 11,145.23 µm |

The platform used Metal 3 for horizontal pin placement and Metal 2 for vertical pin placement.

OpenROAD successfully assigned all 47 I/O pins.

Output database:

`3_2_place_iop.odb`

## 5. Stage 3_3 – Timing-Driven and Routability-Driven Global Placement

Command:

```bash
util/docker_shell make do-3_3_place_gp \
    DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config.mk
```

Global placement was performed using the following optimization options:

```tcl
global_placement \
    -density 0.6 \
    -routability_driven \
    -timing_driven
```

The objective was to optimize cell locations while considering timing constraints and estimated routing congestion.

### Port buffering

Before placement optimization, OpenROAD:

- Removed 282 buffers.
- Inserted 25 input buffers.
- Inserted 21 output buffers.

### Timing-driven optimization

During timing-driven placement, OpenROAD identified electrical violations and performed cell resizing and buffer insertion.

First timing-driven repair iteration:

| Operation | Result |
|---|---:|
| Slew violations identified | 376 |
| Fanout violations identified | 40 |
| Capacitance violations identified | 1 |
| Instances resized | 622 |
| Buffers inserted | 725 |
| Nets repaired | 366 |

A second timing-driven repair iteration was also performed.

### Routability-driven optimization

OpenROAD performed two routability optimization iterations.

| Metric | Iteration 1 | Iteration 2 |
|---|---:|---:|
| Total routing overflow | 0.8835 | 0.5072 |
| Overflowed tiles | 12 | 6 |
| Weighted routing congestion | 1.0370 | 0.9860 |

The target routing congestion was 1.0100.

OpenROAD successfully achieved the configured routing congestion target.

### Final global placement results

| Parameter | Result |
|---|---:|
| Placement iterations | 533 |
| Final overflow | 0.0998 |
| Final HPWL | 193,640.72 µm |
| Final placed cell area | 129,557.45 µm² |
| Final weighted routing congestion | 0.7734 |
| Setup worst slack | +1.20 ns |
| Setup TNS | 0 ns |
| Hold worst slack | +0.47 ns |
| Hold TNS | 0 ns |
| Estimated maximum frequency | 113.65 MHz |

Output database:

`3_3_place_gp.odb`

## 6. Stage 3_4 – Placement Resizing and Buffering

Command:

```bash
util/docker_shell make do-3_4_place_resized \
    DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config.mk
```

OpenROAD performed electrical design repair using:

```tcl
repair_design -verbose -match_cell_footprint
```

### Resizing and buffering results

| Parameter | Result |
|---|---:|
| Slew violations identified | 3 |
| Instances resized | 3 |
| Buffers inserted | 2 |
| Nets repaired | 3 |
| Design area after resizing | 129,388 µm² |
| Reported utilization | 34% |

The resizing operation modifies cell drive strength to improve electrical characteristics such as signal transition time.

Buffer insertion helps drive loads and improve signal distribution.

Output database:

`3_4_place_resized.odb`

## 7. Stage 3_5 – Detailed Placement

Command:

```bash
util/docker_shell make do-3_5_place_dp \
    DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config.mk
```

Detailed placement was performed to legalize standard-cell locations and optimize their physical positions.

### Initial legalization results

| Iteration | Total violations | Illegal cells | Illegal sites |
|---|---:|---:|---:|
| 0 | 3,482 | 700 | 2,782 |
| 1 | 118 | 22 | 96 |
| 2 | 0 | 0 | 0 |

The negotiation legalizer converged successfully in two iterations.

### Placement optimization

OpenROAD performed the following operations:

- Independent set matching.
- Global cell swaps.
- Vertical cell swaps.
- Cell reordering.
- Random placement improvement.
- Cell flipping.

### HPWL optimization

| Stage | HPWL (µm) |
|---|---:|
| Before legalization | 193,632.5 |
| After legalization | 214,968.7 |
| After placement improvement | 206,246.0 |
| After mirroring optimization | 206,064.0 |

Detailed placement increased HPWL initially because cells had to be moved to legal locations. Subsequent placement optimization reduced the resulting wirelength estimate.

### Final placement legality checks

OpenROAD reported:

- 0 cells in wrong regions.
- 0 row alignment problems.
- 0 site alignment problems.
- 0 overlaps between adjacent cells.
- 0 edge-spacing violations.
- 0 padding violations.

Detailed placement completed successfully.

Output database:

`3_5_place_dp.odb`

The final placement constraints file was also generated:

`3_place.sdc`

## 8. Post-Placement Timing Analysis

Timing analysis was performed using placement-based parasitic estimation.

### Timing results

| Metric | Result |
|---|---:|
| Setup worst slack | +1.42 ns |
| Setup TNS | 0 ns |
| Hold worst slack | +0.47 ns |
| Hold TNS | 0 ns |
| Minimum clock period | 8.58 ns |
| Estimated maximum frequency | 116.55 MHz |
| Setup violations | 0 |
| Hold violations | 0 |

The design meets the 100 MHz target in the current post-placement timing analysis.

### Critical timing path

The worst setup path was:

```text
Startpoint:
u_controller.k_idx[0]

Endpoint:
u_mac_array.gen_mac[5].u_mac.acc_value[14]
```

The path passes through multiple buffers, multiplexers, combinational logic, full adders and a half adder before reaching the accumulator register.

Important timing values:

- Data arrival time: 8.50 ns.
- Data required time: 9.70 ns.
- Setup slack: +1.42 ns.

This indicates that the controller-to-MAC accumulator path is the current critical path.

### Asynchronous reset timing

| Check | Endpoint | Slack |
|---|---|---:|
| Reset removal | MAC lane 5, accumulator bit 9 | +0.56 ns |
| Reset recovery | MAC lane 2, accumulator bit 5 | +5.85 ns |

Both asynchronous timing checks passed in the detailed-placement report.

## 9. Electrical Design Rule Checks

Although setup and hold timing checks passed, some maximum-transition violations remained.

| Check | Result |
|---|---:|
| Maximum slew violations | 16 |
| Maximum fanout violations | 0 |
| Maximum capacitance violations | 0 |
| Setup violations | 0 |
| Hold violations | 0 |

The maximum transition limit was 0.50 ns. Some violating pins had approximately 0.51 ns transition.

The remaining slew violations must be investigated during subsequent physical optimization stages.

## 10. Comparison: Floorplan vs Global Placement vs Detailed Placement

| Metric | Day 9 Floorplan | Global Placement | Detailed Placement |
|---|---:|---:|---:|
| Worst setup slack | -3.60 ns | +1.20 ns | +1.42 ns |
| Setup TNS | -1515.68 ns | 0 ns | 0 ns |
| Minimum clock period | 13.60 ns | 8.80 ns | 8.58 ns |
| Estimated frequency | 73.51 MHz | 113.65 MHz | 116.55 MHz |

The placement and timing-driven optimization stages substantially improved the reported timing.

These comparisons involve different physical-design stages and parasitic estimation conditions. They should not be interpreted as a perfectly controlled timing experiment.

## 11. Day 10 Conclusion

The global and detailed placement stages were completed successfully.

Major achievements:

- Performed global placement of 6,041 movable standard-cell instances.
- Assigned physical locations to all 47 I/O pins.
- Completed timing-driven and routability-driven placement.
- Reduced placement overflow to 0.0998.
- Achieved the configured routing congestion target.
- Performed cell resizing and buffer insertion.
- Completed detailed placement legalization with zero remaining placement violations.
- Achieved positive setup and hold slack.
- Obtained an estimated maximum frequency of 116.55 MHz against the 100 MHz target.

The remaining electrical issue is the presence of 16 maximum-slew violations.

The next physical design stage is Clock Tree Synthesis (CTS).

During CTS, the clock distribution network will be constructed using clock buffers and other clock-tree cells. Clock insertion delay, clock skew, setup timing and hold timing will be investigated after CTS.

**Important:** The reported timing results are pre-CTS placement estimates. They do not represent final signoff timing.
