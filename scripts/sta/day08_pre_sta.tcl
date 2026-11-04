# --------------------------------------------------
# Day 8: Pre-layout Static Timing Analysis
# Design: INT8 Matrix Multiplication Accelerator
# Platform: Sky130HD
# --------------------------------------------------

# 1. Read the timing library
read_liberty /work/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# 2. Read the synthesized design database
read_db /work/results/sky130hd/int8_matmul/base/1_synth.odb

# 3. Read timing constraints
read_sdc /work/results/sky130hd/int8_matmul/base/1_synth.sdc

# 4. Report worst setup paths
puts "\n========== SETUP TIMING =========="
report_checks -path_delay max -format full_clock_expanded -digits 4

# 5. Report worst hold paths
puts "\n========== HOLD TIMING =========="
report_checks -path_delay min -format full_clock_expanded -digits 4

# 6. Report worst setup slack
puts "\n========== WORST SETUP SLACK =========="
report_worst_slack -max

# 7. Report worst hold slack
puts "\n========== WORST HOLD SLACK =========="
report_worst_slack -min

# 8. Report total negative slack
puts "\n========== TOTAL NEGATIVE SLACK =========="
report_tns

puts "\n========== STA COMPLETE =========="
