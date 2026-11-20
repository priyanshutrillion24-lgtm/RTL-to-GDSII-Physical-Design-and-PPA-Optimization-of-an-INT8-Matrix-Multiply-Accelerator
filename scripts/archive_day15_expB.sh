#!/usr/bin/env bash
set -euo pipefail

FLOW_HOME="${HOME}/eda/OpenROAD-flow-scripts/flow"
REPO_ROOT="${HOME}/projects/int8-matmul-physical-design"
DESIGN="int8_matmul_expB_util40"

SRC_REPORT="${FLOW_HOME}/reports/sky130hd/${DESIGN}/base"
SRC_LOG="${FLOW_HOME}/logs/sky130hd/${DESIGN}/base"
SRC_RESULTS="${FLOW_HOME}/results/sky130hd/${DESIGN}/base"
SRC_CONFIG="${FLOW_HOME}/designs/sky130hd/int8_matmul/config_expB_util40.mk"

DST_ROOT="${REPO_ROOT}/reports/day15_placement/expB"
DST_REPORT="${DST_ROOT}/reports"
DST_METRICS="${DST_ROOT}/metrics"
DST_LOG="${DST_ROOT}/logs"
DST_RESULTS="${REPO_ROOT}/results/day15_expB"
DST_CONFIG="${REPO_ROOT}/experiments/floorplan/expB_util40/config_expB_util40.mk"

for path in "$SRC_CONFIG" "$SRC_REPORT/3_global_place.rpt" "$SRC_REPORT/3_resizer.rpt" "$SRC_REPORT/3_detailed_place.rpt" "$SRC_LOG/3_3_place_gp.json" "$SRC_LOG/3_5_place_dp.json" "$SRC_RESULTS/3_place.sdc"; do
  if [[ ! -f "$path" ]]; then
    echo "ERROR: Required source artifact not found: $path" >&2
    exit 1
  fi
done

mkdir -p "$DST_REPORT" "$DST_METRICS" "$DST_LOG" "$DST_RESULTS" "$(dirname "$DST_CONFIG")"

# Preserve the existing Day 12 archived configuration; only populate it if absent.
if [[ ! -e "$DST_CONFIG" ]]; then
  cp "$SRC_CONFIG" "$DST_CONFIG"
else
  if ! cmp -s "$SRC_CONFIG" "$DST_CONFIG"; then
    echo "WARNING: Archived Experiment B config differs from the active ORFS config." >&2
    echo "Review both files manually; the existing repository copy was not overwritten." >&2
  fi
fi

for file in 3_global_place.rpt 3_resizer.rpt 3_detailed_place.rpt; do
  cp -f "$SRC_REPORT/$file" "$DST_REPORT/$file"
done

for stage in 3_1_place_gp_skip_io 3_2_place_iop 3_3_place_gp 3_4_place_resized 3_5_place_dp; do
  [[ ! -f "$SRC_LOG/${stage}.json" ]] || cp -f "$SRC_LOG/${stage}.json" "$DST_METRICS/"
  [[ ! -f "$SRC_LOG/${stage}.log" ]] || cp -f "$SRC_LOG/${stage}.log" "$DST_LOG/"
done

cp -f "$SRC_RESULTS/3_place.sdc" "$DST_RESULTS/3_place.sdc"

echo "Day 15 Experiment B artifacts archived under:"
echo "  $DST_ROOT"
echo "  $DST_RESULTS"
echo "Review with:"
echo "  git -C '$REPO_ROOT' status --short"
