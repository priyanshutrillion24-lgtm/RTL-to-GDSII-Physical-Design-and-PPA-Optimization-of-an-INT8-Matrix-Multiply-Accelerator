# Day 6 – Timing Constraints and SDC Development

## 1. Objective

The objective is to define timing constraints for the 8×8 INT8 matrix-multiply accelerator using Synopsys Design Constraints (SDC).

The constraints specify the clock requirements, external input/output timing budgets, clock uncertainty, clock transition and basic design-rule limits.

The constraints will be used during synthesis and static timing analysis.

## 2. Clock Definition

The accelerator operates using a single synchronous clock domain.

| Parameter | Value |
|---|---|
| Clock port | clk |
| Clock name | core_clk |
| Clock period | 10 ns |
| Clock frequency | 100 MHz |
| Duty cycle | 50% |

SDC command:

```tcl
create_clock -name core_clk -period 10.0 [get_ports clk]
```

The clock has a rising edge at 0 ns and a falling edge at 5 ns.

## 3. Clock Uncertainty

Clock uncertainty accounts for clock-related variations such as jitter and skew.

The initial uncertainty assumptions are:

| Constraint | Value |
|---|---:|
| Setup uncertainty | 0.20 ns |
| Hold uncertainty | 0.05 ns |

SDC commands:

```tcl
set_clock_uncertainty -setup 0.20 [get_clocks core_clk]
set_clock_uncertainty -hold 0.05 [get_clocks core_clk]
```

These are initial project assumptions and will be reviewed during timing analysis.

## 4. Clock Transition

An initial clock transition of 0.10 ns is assumed.

```tcl
set_clock_transition 0.10 [get_clocks core_clk]
```

This models the ideal clock source transition during early timing analysis.

Actual clock transitions will be evaluated after Clock Tree Synthesis.

## 5. Input Delay Constraints

Input delays represent the time required for external devices to deliver signals to the accelerator.

The following assumptions are used:

| Parameter | Value |
|---|---:|
| Maximum input delay | 2.0 ns |
| Minimum input delay | 0.20 ns |

SDC commands:

```tcl
set non_clock_inputs [all_inputs -no_clocks]

set_input_delay -max 2.0 -clock core_clk $non_clock_inputs

set_input_delay -min 0.2 -clock core_clk $non_clock_inputs
```

The maximum input delay represents the latest assumed external input arrival.

The minimum input delay represents the earliest assumed external input arrival.

The non-clock input collection includes rst_n as a provisional interface assumption. Asynchronous reset assertion and deassertion require separate review, including recovery/removal considerations.

## 6. Output Delay Constraints

Output delays model the timing requirements of the external receiving device.

The following assumptions are used:

| Parameter | Value |
|---|---:|
| Maximum output delay | 2.0 ns |
| Minimum output delay | -0.20 ns |

SDC commands:

```tcl
set_output_delay -max 2.0 -clock core_clk [all_outputs]

set_output_delay -min -0.2 -clock core_clk [all_outputs]
```

The maximum output delay models the external setup-side timing requirement.

The negative minimum output delay models an assumed 0.20 ns external hold requirement.

## 7. Input Transition

An external input transition of 0.10 ns is assumed.

```tcl
set_input_transition 0.10 $non_clock_inputs
```

This specifies the assumed input signal slew at the accelerator ports.

## 8. Design-Rule Constraints

The initial design-rule limits are:

| Constraint | Value |
|---|---:|
| Maximum transition | 0.50 ns |
| Maximum fanout | 16 |

SDC commands:

```tcl
set_max_transition 0.50 [current_design]

set_max_fanout 16 [current_design]
```

These are provisional project-level limits and are not claimed to be the technology library's mandatory limits.

Maximum capacitance will be specified only after examining the selected standard-cell library.

## 9. Timing Budget

The clock period is 10 ns.

Using the assumed maximum I/O delay of 2 ns and setup uncertainty of 0.20 ns:

\[
T_{budget}=10-2-0.20
\]

\[
T_{budget}=7.8ns
\]

This is a simplified timing-budget calculation. Actual setup slack also accounts for clock arrival times, setup time, cell delay and net delay.

## 10. SDC File Organization

The timing constraints are stored in:

```text
constraints/matmul_top.sdc
```

The SDC file contains:

1. Clock definition.
2. Clock uncertainty.
3. Clock transition.
4. Input delays.
5. Output delays.
6. Input transition.
7. Maximum transition and fanout constraints.

The file will be applied to the synthesized design during the STA stage.

## 11. Important Assumptions and Limitations

- The design uses one clock domain.
- The initial clock period is 10 ns.
- Input/output timing budgets are assumed, not measured from an external system.
- Clock uncertainty values are initial estimates.
- Clock transition is initially modeled as an ideal-clock assumption.
- Reset is asynchronous and requires separate recovery/removal and deassertion review.
- Maximum transition and fanout values are provisional project-level constraints.
- Output load and maximum capacitance will be refined after examining the technology library.

## 12. Day 6 Conclusion

The initial timing constraints for the INT8 matrix-multiply accelerator have been defined.

The SDC file specifies a 10 ns clock, setup/hold uncertainty, external input/output timing budgets, signal transition assumptions and basic design-rule constraints.

The next stage is to perform synthesis and establish the pre-layout timing baseline using the synthesized netlist and timing constraints.

Actual timing results will be recorded during the subsequent synthesis and STA experiments.
