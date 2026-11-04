# Read library
read_liberty /work/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Read synthesized database
read_db /work/results/sky130hd/int8_matmul/base/1_synth.odb

# Read timing constraints
read_sdc /work/results/sky130hd/int8_matmul/base/1_synth.sdc

# ------------------------------------------
# Detailed setup paths
# ------------------------------------------
puts "\n========== DETAILED SETUP PATHS =========="

report_checks \
    -path_delay max \
    -group_path_count 10 \
    -endpoint_path_count 3 \
    -format full_clock_expanded \
    -fields {slew capacitance fanout input_pin net} \
    -digits 4

# ------------------------------------------
# Detailed hold paths
# ------------------------------------------
puts "\n========== DETAILED MINIMUM PATHS =========="

report_checks \
    -path_delay min \
    -group_path_count 10 \
    -endpoint_path_count 3 \
    -format full_clock_expanded \
    -fields {slew capacitance fanout input_pin net} \
    -digits 4

# ------------------------------------------
# Asynchronous reset checks
# ------------------------------------------
puts "\n========== RECOVERY AND REMOVAL VIOLATIONS =========="

report_check_types -recovery -removal -violators

# ------------------------------------------
# Ordinary setup and hold violations
# ------------------------------------------
puts "\n========== SETUP VIOLATIONS =========="

report_check_types -max_delay -violators

puts "\n========== HOLD VIOLATIONS =========="

report_check_types -min_delay -violators

# ------------------------------------------
# Electrical violations
# ------------------------------------------
puts "\n========== SLEW, CAPACITANCE AND FANOUT =========="

report_check_types \
    -max_slew \
    -max_capacitance \
    -max_fanout \
    -violators

puts "\n========== DETAILED STA COMPLETE =========="
