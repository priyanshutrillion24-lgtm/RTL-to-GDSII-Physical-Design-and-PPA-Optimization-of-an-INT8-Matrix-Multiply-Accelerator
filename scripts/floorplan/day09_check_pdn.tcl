read_liberty /work/platforms/sky130hd/lib/sky130_fd_sc_hd__tt_025C_1v80.lib

read_db /work/results/sky130hd/int8_matmul/base/2_4_floorplan_pdn.odb

check_power_grid -net VDD -floorplanning
check_power_grid -net VSS -floorplanning

exit
