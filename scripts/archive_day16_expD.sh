#!/usr/bin/env bash
set -euo pipefail

# Run this script from anywhere inside the project Git repository.
REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "ERROR: Run this script from inside the project Git repository." >&2
  exit 1
}
ORFS_FLOW="${ORFS_FLOW:-$HOME/eda/OpenROAD-flow-scripts/flow}"
EXP="int8_matmul_expD_timing_w8"
BASE="$ORFS_FLOW"

CONFIG="$BASE/designs/sky130hd/int8_matmul/config_expD_timing_w8.mk"
REPORT_DIR="$BASE/reports/sky130hd/$EXP/base"
LOG_DIR="$BASE/logs/sky130hd/$EXP/base"
RESULT_DIR="$BASE/results/sky130hd/$EXP/base"

for required in "$CONFIG" "$REPORT_DIR/3_detailed_place.rpt" \
                "$LOG_DIR/3_3_place_gp.log" "$LOG_DIR/3_3_place_gp.json" \
                "$LOG_DIR/3_5_place_dp.json" "$RESULT_DIR/3_place.odb" \
                "$RESULT_DIR/3_place.sdc"; do
  if [[ ! -f "$required" ]]; then
    echo "ERROR: Required artifact not found: $required" >&2
    exit 1
  fi
done

mkdir -p \
  "$REPO_ROOT/configs/day16" \
  "$REPO_ROOT/reports/day16_timing_driven/expD" \
  "$REPO_ROOT/logs/day16_timing_driven/expD" \
  "$REPO_ROOT/results/day16_expD"

cp -f "$CONFIG" "$REPO_ROOT/configs/day16/"

for file in 3_global_place.rpt 3_resizer.rpt 3_detailed_place.rpt; do
  [[ ! -f "$REPORT_DIR/$file" ]] || cp -f "$REPORT_DIR/$file" "$REPO_ROOT/reports/day16_timing_driven/expD/"
done

for stage in 3_1_place_gp_skip_io 3_2_place_iop 3_3_place_gp 3_4_place_resized 3_5_place_dp; do
  for ext in log json; do
    [[ ! -f "$LOG_DIR/$stage.$ext" ]] || cp -f "$LOG_DIR/$stage.$ext" "$REPO_ROOT/logs/day16_timing_driven/expD/"
  done
done

cp -f "$RESULT_DIR/3_place.odb" "$REPO_ROOT/results/day16_expD/"
cp -f "$RESULT_DIR/3_place.sdc" "$REPO_ROOT/results/day16_expD/"

echo "Day 16 Experiment D artifacts archived under:"
echo "  $REPO_ROOT/configs/day16"
echo "  $REPO_ROOT/reports/day16_timing_driven/expD"
echo "  $REPO_ROOT/logs/day16_timing_driven/expD"
echo "  $REPO_ROOT/results/day16_expD"
