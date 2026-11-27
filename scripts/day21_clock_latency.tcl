read_liberty /work/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db /work/results/sky130hd/int8_matmul_expB_util40/base/4_cts.odb

read_sdc /work/results/sky130hd/int8_matmul_expB_util40/base/4_cts.sdc

source /work/platforms/sky130hd/setRC.tcl

set_propagated_clock [all_clocks]
estimate_parasitics -placement

puts "\n========== CLOCK LATENCY =========="
report_clock_latency -clocks [get_clocks core_clk] -digits 4

puts "\n========== SETUP CLOCK SKEW =========="
report_clock_skew -setup -digits 4

puts "\n========== HOLD CLOCK SKEW =========="
report_clock_skew -hold -digits 4


exit
