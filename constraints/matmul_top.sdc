
# ==========================================================
# Project: INT8 Matrix-Multiply Accelerator
# Top module: matmul_top
# Day 6: Timing Constraints
# ==========================================================

current_design matmul_top

# ----------------------------------------------------------
# 1. CLOCK DEFINITION
# ----------------------------------------------------------

set clk_name   core_clk
set clk_period 10.0

create_clock -name $clk_name \
    -period $clk_period \
    [get_ports clk]


# ----------------------------------------------------------
# 2. CLOCK UNCERTAINTY
# ----------------------------------------------------------

# Setup uncertainty: 0.20 ns
set_clock_uncertainty -setup 0.20 \
    [get_clocks $clk_name]

# Hold uncertainty: 0.05 ns
set_clock_uncertainty -hold 0.05 \
    [get_clocks $clk_name]


# ----------------------------------------------------------
# 3. CLOCK TRANSITION
# ----------------------------------------------------------

set_clock_transition 0.10 [get_clocks $clk_name]


# ----------------------------------------------------------
# 4. INPUT DELAYS
# ----------------------------------------------------------

# All external input ports except clock
# Includes rst_n as a provisional interface assumption.
set non_clock_inputs [all_inputs -no_clocks]

# Maximum input arrival time: 2.0 ns
set_input_delay -max 2.0 \
    -clock $clk_name $non_clock_inputs

# Minimum input arrival time: 0.2 ns
set_input_delay -min 0.2 \
    -clock $clk_name $non_clock_inputs


# ----------------------------------------------------------
# 5. OUTPUT DELAYS
# ----------------------------------------------------------

set output_ports [all_outputs]

# Maximum output delay: 2.0 ns
set_output_delay -max 2.0 \
    -clock $clk_name $output_ports

# External receiver hold requirement: 0.2 ns
set_output_delay -min -0.2 \
    -clock $clk_name $output_ports


# ----------------------------------------------------------
# 6. INPUT TRANSITION
# ----------------------------------------------------------

set_input_transition 0.10 $non_clock_inputs


# ----------------------------------------------------------
# 7. DESIGN-RULE CONSTRAINTS
# ----------------------------------------------------------

# Initial maximum transition target: 0.50 ns
set_max_transition 0.50 [current_design]

# Initial maximum fanout target: 16
set_max_fanout 16 [current_design]


# ==========================================================
# END OF SDC
# ==========================================================
