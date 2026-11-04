# --------------------------------------------------
# Register-to-register timing analysis
# INT8 Matrix Multiplication Accelerator
# --------------------------------------------------

read_liberty /work/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db /work/results/sky130hd/int8_matmul/base/1_synth.odb

read_sdc /work/results/sky130hd/int8_matmul/base/1_synth.sdc

# Collect register output pins (Q)
set reg_q [all_registers -output_pins]

# Collect register data pins (D)
set reg_d [all_registers -data_pins]

puts "\n========== REGISTER-TO-REGISTER SETUP PATHS =========="

report_checks \
    -from $reg_q \
    -to $reg_d \
    -path_delay max \
    -group_path_count 10 \
    -endpoint_path_count 1 \
    -format full_clock_expanded \
    -fields {slew capacitance fanout input_pin net} \
    -digits 4

puts "\n========== INTERNAL STA COMPLETE =========="
