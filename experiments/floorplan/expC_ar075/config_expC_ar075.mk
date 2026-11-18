export DESIGN_NICKNAME = int8_matmul_expC_ar075
export DESIGN_NAME = matmul_top
export PLATFORM = sky130hd

# Reuse original INT8 matrix multiplier RTL
export VERILOG_FILES = $(sort $(wildcard /work/designs/src/int8_matmul/*.sv))

# Reuse original timing constraints
export SDC_FILE = /work/designs/sky130hd/int8_matmul/constraint.sdc

export SYNTH_HDL_FRONTEND = slang

# Keep utilization identical to Experiment B
export CORE_UTILIZATION = 40

# Experiment C: rectangular floorplan
export CORE_ASPECT_RATIO = 0.75

# Keep placement density unchanged
export PLACE_DENSITY = 0.60

export TNS_END_PERCENT = 100
