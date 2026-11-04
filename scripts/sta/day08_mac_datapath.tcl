# --------------------------------------------------
# Day 8: Isolated MAC datapath timing
# --------------------------------------------------

read_liberty /work/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db /work/results/sky130hd/int8_matmul/base/1_synth.odb

read_sdc /work/results/sky130hd/int8_matmul/base/1_synth.sdc

# All sequential register output pins
set reg_q [all_registers -output_pins]

# Find MAC accumulator register cells
set acc_cells [get_cells -hierarchical {*acc_value*}]

# Find only their data-input pins (D)
set acc_d [get_pins -of_objects $acc_cells -filter "name==D"]

# Find result-storage register cells
set result_cells [get_cells -hierarchical {*result_mem*}]

# Find only their data-input pins (D)
set result_d [get_pins -of_objects $result_cells -filter "name==D"]

# Print collection sizes for verification
puts "\n========== COLLECTION CHECK =========="
puts "Accumulator cells: [llength $acc_cells]"
puts "Accumulator D pins: [llength $acc_d]"
puts "Result storage cells: [llength $result_cells]"
puts "Result storage D pins: [llength $result_d]"

# MAC accumulator data paths
puts "\n========== MAC ACCUMULATOR DATA PATHS =========="

report_checks \
    -from $reg_q \
    -to $acc_d \
    -path_delay max \
    -group_path_count 10 \
    -endpoint_path_count 1 \
    -format full_clock_expanded \
    -fields {slew capacitance fanout input_pin net} \
    -digits 4

# Computed-result data paths
puts "\n========== RESULT STORAGE DATA PATHS =========="

report_checks \
    -from $reg_q \
    -to $result_d \
    -path_delay max \
    -group_path_count 10 \
    -endpoint_path_count 1 \
    -format full_clock_expanded \
    -fields {slew capacitance fanout input_pin net} \
    -digits 4

puts "\n========== DATAPATH STA COMPLETE =========="
