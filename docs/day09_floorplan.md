
# Day 09 – Floorplanning and Power Distribution Network

## 1. Objective

The objective of Day 9 was to perform floorplanning of the INT8 matrix multiplication accelerator using the OpenROAD physical design flow.

The activities included:
- Floorplan initialization
- Macro placement
- Tap-cell insertion
- Power Distribution Network (PDN) generation
- PDN connectivity verification
- Floorplan timing analysis

## 2. Floorplan Initialization

The floorplan was initialized using the following configuration:

- Platform: Sky130HD
- Core utilization target: 30%
- Aspect ratio: 1.0
- Core space: 1.0 µm

### Floorplan results

| Parameter | Result |
|---|---:|
| Number of instances | 6,041 |
| Die dimensions | 621.495 × 621.495 µm² |
| Core area | 382,010.128 µm² |
| Total instance area | 115,132.922 µm² |
| Effective utilization | 30.1% |
| Number of standard-cell rows | 227 |
| Sites per row | 1,345 |

## 3. Macro Placement

The macro placement stage was executed.

OpenROAD reported that no macros were found, so macro placement was skipped.

This is expected because the current accelerator uses register-based storage rather than hard SRAM macros.

## 4. Tap-Cell Insertion

Tap cells were inserted during the floorplanning flow.

Results:

- Number of tap cells inserted: 5,038
- Reported design area after insertion: 121,449 µm²
- Reported utilization after insertion: 32%

Tap cells provide well and substrate connections to help prevent latch-up in CMOS circuits.

## 5. Power Distribution Network Generation

The PDN generation stage completed successfully.

OpenROAD reported:

```text
[INFO PDN-0001] Inserting grid: grid
```

The following warnings were also observed:

```text
[WARNING PDN-1051] No instances found for grid (CORE_macro_grid_1).
[WARNING PDN-1051] No instances found for grid (CORE_macro_grid_2).
```

These warnings are associated with macro-specific grids. Since the current design has no hard macros, these warnings are expected.

The main PDN grid was inserted successfully.

## 6. PDN Connectivity Verification

A Tcl script was created to verify VDD and VSS connectivity.

The commands used were:

```tcl
check_power_grid -net VDD -floorplanning
check_power_grid -net VSS -floorplanning
```

OpenROAD reported:

```text
[INFO PSM-0040] All shapes on net VDD are connected.
[INFO PSM-0040] All shapes on net VSS are connected.
```

Both connectivity checks passed.

Note: This confirms connectivity of the PDN shapes. It does not constitute IR-drop or electromigration analysis.

## 7. Floorplan Timing Analysis

The final floorplan timing report showed:

| Metric | Result |
|---|---:|
| Worst Negative Slack (WNS) | -3.60 ns |
| Total Negative Slack (TNS) | -1515.68 ns |
| Minimum clock period | 13.60 ns |
| Corresponding maximum frequency | 73.51 MHz |

The target clock period is 10 ns (100 MHz).

Therefore, the design does not yet meet the target frequency.

### Critical timing path

The worst setup path was:

```text
rst_n
  → control logic
  → NOR3
  → result_mem[32][0]/DE
```

Important observations:

- Endpoint: Data-enable (DE) pin of an enabled flip-flop.
- Final logic cell: sky130_fd_sc_hd__nor3_1
- Output net fanout: 152
- Capacitance: 0.52 pF
- Output slew: 13.80 ns
- NOR3 cell delay: 10.31 ns

The critical path is associated with a high-fanout control/enable signal rather than the MAC arithmetic datapath.

An asynchronous reset removal violation of -0.20 ns was also reported and should be investigated separately.

### Timing repair observation

During floorplan initialization, OpenROAD attempted timing repair using wire-load models because estimated parasitics were not available.

The WNS improved from approximately -7.80 ns to -3.60 ns, but timing violations remained.

These are preliminary floorplan-stage timing results. Placement and more realistic parasitic estimation are required for further evaluation.

## 8. Day 9 Conclusion

The floorplanning stage completed successfully.

Completed activities:

- Floorplan initialization
- Macro placement stage
- Tap-cell insertion
- PDN generation
- VDD connectivity verification
- VSS connectivity verification
- Floorplan timing analysis

The primary remaining physical design concern is the high-fanout control/enable path causing setup violations.

The next stage will focus on global placement, placement density, congestion and timing optimization.
