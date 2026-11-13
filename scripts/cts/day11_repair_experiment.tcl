# ============================================
# DAY 11 - POST CTS REPAIR EXPERIMENT
# ============================================

# Read timing library
read_liberty /work/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

# Load original CTS database
read_db /work/results/sky130hd/int8_matmul/base/4_cts.odb

# Load CTS timing constraints
read_sdc /work/results/sky130hd/int8_matmul/base/4_cts.sdc

# Load RC settings
source /OpenROAD-flow-scripts/flow/platforms/sky130hd/setRC.tcl

# Estimate parasitics
estimate_parasitics -placement

puts "\n========== BEFORE REPAIR =========="

report_check_types -max_slew -max_fanout -max_capacitance -violators

# Repair data-net electrical violations
repair_design -verbose -match_cell_footprint

# Re-estimate parasitics
estimate_parasitics -placement

puts "\n========== AFTER REPAIR =========="

report_check_types -max_slew -max_fanout -max_capacitance -violators

# Check setup and hold timing
report_checks -path_delay max -format full_clock_expanded
report_checks -path_delay min -format full_clock_expanded

# Save repaired database separately
write_db /work/day11_cts_repaired.odb
write_sdc /work/day11_cts_repaired.sdc

exit
