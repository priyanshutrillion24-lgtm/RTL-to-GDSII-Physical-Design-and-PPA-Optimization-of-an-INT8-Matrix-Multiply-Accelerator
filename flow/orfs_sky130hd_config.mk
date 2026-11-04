
# ==============================================
# INT8 Matrix-Multiply Accelerator
# ORFS Design Configuration
# ==============================================

# Design identification
export DESIGN_NICKNAME = int8_matmul
export DESIGN_NAME = matmul_top

# Technology platform
export PLATFORM = sky130hd

export VERILOG_FILES = $(sort $(wildcard /work/designs/src/$(DESIGN_NICKNAME)/*.sv))

export SDC_FILE = /work/designs/$(PLATFORM)/$(DESIGN_NICKNAME)/constraint.sdc
# SystemVerilog frontend
export SYNTH_HDL_FRONTEND = slang

# Initial floorplan settings for later stages
export CORE_UTILIZATION = 30
export PLACE_DENSITY = 0.60

# Timing report configuration
export TNS_END_PERCENT = 100
