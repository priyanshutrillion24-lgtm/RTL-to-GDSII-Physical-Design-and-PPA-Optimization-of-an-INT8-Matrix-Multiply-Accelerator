# Day 20 — Introduction to Clock Tree Synthesis

**Date:** 26 November 2026
**Design:** matmul_top
**Platform:** Sky130HD
**Selected placement checkpoint:** Experiment B

## 1. Objective

Understand the clock-distribution problem, the purpose of Clock Tree
Synthesis (CTS), important clock timing concepts, and the CTS implementation
in the installed OpenROAD Flow Scripts (ORFS) version.

This day covers concepts and flow inspection. CTS has not been run yet.

## 2. What is CTS?

Clock Tree Synthesis is the process of constructing a physical clock
distribution network to deliver the clock to sequential elements.

The CTS tool inserts clock buffers and creates a branching network to
distribute the clock while controlling clock arrival times, transition
times, electrical loading, area and power.

A typical clock tree has:
- Root-level clock buffers
- Intermediate branch buffers
- Leaf-level buffers driving local clock sinks

A clock sink is generally the clock pin of a sequential element.

## 3. Why is CTS required?

A clock source driving many sequential elements encounters capacitive
loading and interconnect resistance. A single driver may not provide
acceptable transition time or delay across the entire design.

A buffered clock tree distributes the load across multiple stages and
physical regions.

CTS aims to control:
- Clock skew
- Clock insertion delay
- Clock transition time
- Clock-tree area
- Clock-network power
- Setup and hold timing

Adding buffers also increases cell area and clock-network capacitance.
More buffers are not automatically better.

## 4. Important clock concepts

### 4.1 Clock latency

Clock latency is the time taken for the clock to reach a point in the clock
network, relative to its clock reference.

Source latency represents delay from the external reference to the clock
input port. Network latency represents delay through the internal clock
distribution network to a clock sink.

### 4.2 Clock insertion delay

Clock insertion delay is the delay through the implemented clock
distribution network. It includes clock-buffer and interconnect delays.

Simplified representation:

T_insertion = T_buffer_delays + T_wire_delays

### 4.3 Clock skew

Clock skew is the difference in clock arrival times at two sequential
elements.

For a launch and capture pair:

T_skew = T_capture_clock - T_launch_clock

- Positive skew: capture clock arrives later than launch clock.
- Negative skew: capture clock arrives earlier than launch clock.

### 4.4 Effect of skew on setup and hold

Simplified setup relationship:

T_cq,max + T_data,max + T_setup
    <= T_period + T_skew - T_setup_uncertainty

Positive skew generally helps setup because the capture edge arrives later.

Simplified hold relationship:

T_cq,min + T_data,min
    >= T_skew + T_hold + T_hold_uncertainty

Positive skew generally hurts hold because the minimum data-path delay
requirement increases.

These are simplified single-clock relationships. Full static timing
analysis considers the complete launch and capture clock paths and timing
exceptions.

### 4.5 Clock slew

Clock slew describes how quickly the clock signal transitions between
logic levels. Excessive slew can violate electrical limits and affect
timing behavior.

### 4.6 Clock uncertainty

Clock uncertainty is a timing margin used to account for effects such as
clock jitter and other variations. It is not a physical clock buffer or
wire delay.

## 5. SDC clock constraints for this design

The Experiment B SDC defines:

| Constraint | Value |
|---|---:|
| Clock name | core_clk |
| Clock input port | clk |
| Clock period | 10.0 ns |
| Target frequency | 100 MHz |
| Setup uncertainty | 0.20 ns |
| Hold uncertainty | 0.05 ns |
| Clock transition assumption | 0.10 ns |
| Maximum transition | 0.50 ns |
| Maximum fanout | 16 |
| Maximum input delay | 2.0 ns |
| Minimum input delay | 0.2 ns |
| Maximum output delay | 2.0 ns |
| Minimum output delay | -0.2 ns |

The target frequency follows from:

f = 1 / T = 1 / 10 ns = 100 MHz

There is no explicit set_clock_latency command and no
create_generated_clock command in the inspected SDC.

The 0.10 ns clock transition is an SDC assumption. It is not the measured
post-CTS clock transition.

## 6. Installed ORFS CTS implementation

The implementation was inspected in:

scripts/cts.tcl

The relevant command construction is:

    set cts_args [list \
      -sink_clustering_enable \
      -repair_clock_nets]

    append_env_var cts_args CTS_BUF_DISTANCE -distance_between_buffers 1
    append_env_var cts_args CTS_CLUSTER_SIZE -sink_clustering_size 1
    append_env_var cts_args CTS_CLUSTER_DIAMETER -sink_clustering_max_diameter 1
    append_env_var cts_args CTS_BUF_LIST -buf_list 1
    append_env_var cts_args CTS_LIB_NAME -library 1

    if { [env_var_exists_and_non_empty CTS_ARGS] } {
      set cts_args $::env(CTS_ARGS)
    }

    log_cmd clock_tree_synthesis {*}$cts_args

The installed script explicitly enables sink clustering and clock-net
repair. CTS_ARGS, when non-empty, overrides the assembled CTS arguments.

The Experiment B configuration and Sky130HD platform configuration did
not contain explicit CTS-variable overrides.

The following settings were not explicitly specified in those two
configuration files:

- CTS buffer distance
- CTS buffer list
- CTS Liberty library name
- Maximum cluster size
- Maximum cluster diameter

The actual runtime choices for these settings should be confirmed from
the CTS invocation and logs rather than assumed.

### 6.1 CTS timing repair and snapshots

The installed ORFS variable definitions showed:

| Variable | Default | Meaning |
|---|---:|---|
| SKIP_CTS_REPAIR_TIMING | 0 | CTS-stage timing repair is enabled |
| CTS_SNAPSHOTS | 0 | Intermediate CTS snapshots are disabled |

Because SKIP_CTS_REPAIR_TIMING is 0, the installed CTS script calls
repair_timing_helper after clock-tree construction.

### 6.2 Clock-skew reporting

The installed report_metrics.tcl checks REPORT_CLOCK_SKEW before
calling report_clock_skew.

The effective default of REPORT_CLOCK_SKEW has not yet been verified
from the local variable definition. It should not be assumed.

## 7. CTS stage sequence in scripts/cts.tcl

The inspected script performs these operations:

1. Load 3_place.odb and 3_place.sdc.
2. Source PRE_CTS_TCL, if configured.
3. Run repair_clock_inverters.
4. Run clock_tree_synthesis.
5. Estimate parasitics using placement-based estimates.
6. Run detailed placement.
7. If SKIP_CTS_REPAIR_TIMING is 0, run repair_timing_helper.
8. Run detailed placement and estimate parasitics again after timing repair.
9. Generate final CTS metrics.
10. Source POST_CTS_TCL, if configured.
11. Write 4_1_cts.odb and 4_cts.sdc.

The final CTS database can contain timing-repair changes in addition to
the inserted clock-tree cells.

## 8. Useful OpenROAD CTS commands

| Command | Purpose |
|---|---|
| clock_tree_synthesis | Construct the clock tree |
| report_cts | Report clock roots, buffers, subnets and sinks |
| report_clock_skew | Report clock arrival differences |
| estimate_parasitics -placement | Estimate parasitics using placement |

The installed ORFS flow invokes clock_tree_synthesis from scripts/cts.tcl.

## 9. Day 20 conclusions

- CTS creates a physical clock-distribution network.
- Clock skew is the difference between clock arrival times at two sinks.
- Positive skew generally helps setup and hurts hold.
- Clock insertion delay, clock slew and clock uncertainty are distinct
  concepts.
- The design clock target is 100 MHz.
- The inspected ORFS CTS script enables sink clustering and clock-net repair.
- CTS-stage timing repair is enabled by default in the inspected script.
- Some CTS parameter values remain to be verified from the runtime logs.
- The Experiment B placement checkpoint remains frozen.
- No CTS implementation run was performed on Day 20.

## 10. References and inspected files

OpenROAD Clock Tree Synthesis documentation:
https://openroad.readthedocs.io/en/latest/main/src/cts/README.html

OpenROAD Flow Scripts variable documentation:
https://openroad-flow-scripts.readthedocs.io/en/latest/user/FlowVariables.html

Local files inspected:
- scripts/cts.tcl
- scripts/variables.yaml
- scripts/report_metrics.tcl
- designs/sky130hd/int8_matmul/constraint.sdc
- designs/sky130hd/int8_matmul/config_expB_util40.mk
- platforms/sky130hd/config.mk
