export DESIGN_NICKNAME = int8_matmul_expB_util40
export DESIGN_NAME = matmul_top
export PLATFORM = sky130hd

# Reuse the original INT8 accelerator RTL
export VERILOG_FILES = $(sort $(wildcard /work/designs/src/int8_matmul/*.sv))

# Reuse the original timing constraints
export SDC_FILE = /work/designs/sky130hd/int8_matmul/constraint.sdc

export SYNTH_HDL_FRONTEND = slang

# Experiment B: increased core utilization
export CORE_UTILIZATION = 40

# Keep placement density constant
export PLACE_DENSITY = 0.60

export TNS_END_PERCENT = 100
