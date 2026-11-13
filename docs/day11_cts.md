# Day 11 – Clock Tree Synthesis (CTS)

**Project:** INT8 Matrix Multiplication Accelerator  
**Technology:** Sky130HD  
**Physical Design Flow:** OpenROAD-flow-scripts (ORFS)  
**Date:** November 13, 2026

## 1. Objective

The objective of Day 11 was to perform Clock Tree Synthesis (CTS) for the INT8 matrix multiplication accelerator.

CTS distributes the clock signal to sequential elements while controlling clock latency, skew, transition time, and clock-tree loading.

The work included generating the clock tree, analyzing post-CTS timing, investigating electrical violations, and conducting a data-net repair experiment.

## 2. CTS Implementation

CTS was executed using the OpenROAD-flow-scripts flow.

**Command:**

```bash
util/docker_shell make do-4_1_cts \
    DESIGN_CONFIG=/work/designs/sky130hd/int8_matmul/config.mk
```

The CTS command used by the flow was:

```tcl
clock_tree_synthesis \
    -sink_clustering_enable \
    -repair_clock_nets
```

No design-specific CTS overrides were found in the Sky130HD platform or INT8 matrix-multiplication design configuration files.

### 2.1 Clock Tree Statistics

| Parameter | Result |
|---|---:|
| Clock buffers created | 242 |
| Clock-tree levels | 4 |
| Register sink clusters after clustering | 217 |
| Hold buffers inserted during timing repair | 6 |
| Clock nets | 242 |
| Clock sink count before clustering | 2,401 |

The generated clock tree used an H-tree topology.

The CTS stage completed successfully and generated the post-CTS database and SDC files.

## 3. Post-CTS Timing Analysis

The final CTS timing report was examined to evaluate setup, hold, and clock-skew characteristics.

| Parameter | Result |
|---|---:|
| Clock period | 10 ns |
| Minimum clock period | 8.58 ns |
| Estimated maximum frequency | 116.51 MHz |
| Setup worst slack | +1.42 ns |
| Hold worst slack | +0.062 ns |
| Setup TNS | 0 ns |
| Hold TNS | 0 ns |
| Reported setup clock skew | 0.32 ns |
| Setup violations | 0 |
| Hold violations | 0 |

### 3.1 Critical Setup Path

The critical setup path remained:

**Startpoint:** `u_controller.k_idx[0]`

**Endpoint:** `u_mac_array.gen_mac[5].u_mac.acc_value[14]/D`

The path includes multiplexers, buffers, full adders, a half adder, and combinational logic associated with the MAC datapath.

The reported setup slack was approximately +1.42 ns.

### 3.2 Hold Timing

The worst ordinary data-path hold slack was approximately +0.062 ns.

The asynchronous reset removal check had a positive slack of approximately +0.13 ns.

Both checks passed, although the hold and reset-removal margins are relatively small and should be monitored during subsequent stages.

## 4. Post-CTS Electrical Checks

The initial post-CTS electrical checks reported:

| Check | Number of violations |
|---|---:|
| Maximum slew | 16 |
| Maximum fanout | 5 |
| Maximum capacitance | 0 |

### 4.1 Maximum Slew Investigation

Connectivity analysis identified three principal nets associated with the slew violations.

**Net 1: `acc_value_next_bus[147]`**

- Driver instance: `_4606_`
- Driver cell: `sky130_fd_sc_hd__xor2_2`
- Connected input loads: 9
- Eight loads were result-memory D pins at bit 14.
- One additional load was `_6691_/A1`.

The eight affected result-memory pins shared this net, indicating a common loading problem rather than eight independent data nets.

**Net 2: `_1363_`**

- Driver instance: `_4793_`
- Driver cell: `sky130_fd_sc_hd__o21ai_0`
- Connected load included `_4794_/B`.

**Net 3: `_1097_`**

- Driver instance: `_6903_`
- Driver cell: `sky130_fd_sc_hd__nor2_4`
- Connected loads included three buffer input pins.

### 4.2 Maximum Fanout Investigation

Five clock-buffer output pins exceeded the configured maximum fanout of 16.

| Clock buffer output | Observed fanout | Limit |
|---|---:|---:|
| `clkbuf_4_13__f_clk/X` | 19 | 16 |
| `clkbuf_4_8__f_clk/X` | 19 | 16 |
| `clkbuf_4_0__f_clk/X` | 17 | 16 |
| `clkbuf_4_1__f_clk/X` | 17 | 16 |
| `clkbuf_4_2__f_clk/X` | 17 | 16 |

Connectivity inspection showed that these parent clock-buffer outputs drive multiple leaf clock-buffer inputs.

The SDC constraint remains:

```tcl
set_max_fanout 16 [current_design]
```

The five clock-tree fanout violations remain outstanding.

## 5. Data-Net Repair Experiment

A separate OpenROAD repair experiment was performed using the original post-CTS database.

The experiment used:

```tcl
estimate_parasitics -placement

repair_design -verbose -match_cell_footprint

estimate_parasitics -placement
```

### 5.1 Repair Results

OpenROAD reported:

- 3 slew-violating nets found.
- 2 instances resized.
- 1 buffer inserted.
- 3 nets repaired.

After the repair experiment, the maximum-slew violation table was no longer reported. No maximum-capacitance violations were reported.

The five maximum-fanout violations on the clock tree remained.

### 5.2 Post-Repair Timing

| Parameter | Post-repair result |
|---|---:|
| Setup slack | +1.42 ns |
| Hold slack | +0.062 ns |
| Reset recovery slack | +6.22 ns |
| Reset removal slack | +0.13 ns |

The reported setup and hold margins remained positive.

### 5.3 Repaired Database

The repair experiment generated separate output files:

- `day11_cts_repaired.odb`
- `day11_cts_repaired.sdc`

These files are retained separately from the standard ORFS CTS database to preserve the original CTS implementation as a baseline.

## 6. Observations

1. CTS successfully generated a four-level H-tree clock distribution network.
2. A total of 242 clock buffers were created.
3. Six hold buffers were inserted during CTS timing repair.
4. Post-CTS setup and hold timing checks reported no violations.
5. The initial electrical checks identified 16 maximum-slew violations and 5 maximum-fanout violations.
6. Connectivity analysis showed that the result-memory slew violations were concentrated on a shared data net.
7. The data-net repair experiment resized two instances and inserted one buffer.
8. No maximum-slew or maximum-capacitance violation table was reported after the repair experiment.
9. Five clock-buffer maximum-fanout violations remain outstanding.
10. The repaired database was generated separately to preserve the baseline CTS database.

## 7. Conclusion

Clock Tree Synthesis was successfully completed for the INT8 matrix multiplication accelerator using the Sky130HD technology.

The post-CTS design achieved positive setup and hold slack, with an estimated maximum operating frequency of approximately 116.51 MHz.

A targeted repair experiment addressed the identified data-net slew violations without changing the reported critical setup and hold margins.

However, five maximum-fanout violations remain on clock-tree parent buffer outputs. These violations are documented for continued evaluation during subsequent physical-design stages.

The CTS reports, metrics, diagnostic scripts, and repair experiment outputs are retained for reproducibility.

**Next stage:** Day 12 – Global Routing.
