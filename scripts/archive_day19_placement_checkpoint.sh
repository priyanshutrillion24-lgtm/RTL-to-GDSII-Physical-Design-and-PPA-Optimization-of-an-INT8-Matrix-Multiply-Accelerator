#!/usr/bin/env bash
set -euo pipefail

FLOW_HOME="${HOME}/eda/OpenROAD-flow-scripts/flow"
REPO_ROOT="${HOME}/projects/int8-matmul-physical-design"
DESIGN="int8_matmul_expB_util40"

SRC_REPORT="${FLOW_HOME}/reports/sky130hd/${DESIGN}/base"
SRC_LOG="${FLOW_HOME}/logs/sky130hd/${DESIGN}/base"
SRC_RESULTS="${FLOW_HOME}/results/sky130hd/${DESIGN}/base"
SRC_CONFIG="${FLOW_HOME}/designs/sky130hd/int8_matmul/config_expB_util40.mk"

DST_ROOT="${REPO_ROOT}/reports/day19_placement_checkpoint/expB"
DST_REPORT="${DST_ROOT}/reports"
DST_METRICS="${DST_ROOT}/metrics"
DST_LOG="${DST_ROOT}/logs"
DST_RESULTS="${REPO_ROOT}/results/day19_expB"
DST_CONFIG="${DST_ROOT}/config_expB_util40.mk"

# Validate the required checkpoint artifacts before copying anything.
required_files=(
  "$SRC_CONFIG"
  "$SRC_REPORT/2_floorplan_final.rpt"
  "$SRC_REPORT/3_global_place.rpt"
  "$SRC_REPORT/3_resizer.rpt"
  "$SRC_REPORT/3_detailed_place.rpt"
  "$SRC_RESULTS/3_place.odb"
  "$SRC_RESULTS/3_place.sdc"
)

stages=(
  3_1_place_gp_skip_io
  3_2_place_iop
  3_3_place_gp
  3_4_place_resized
  3_5_place_dp
)

for stage in "${stages[@]}"; do
  required_files+=("$SRC_LOG/${stage}.log")
  required_files+=("$SRC_LOG/${stage}.json")
done

for file in "${required_files[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "ERROR: Required source artifact missing or empty: $file" >&2
    exit 1
  fi
done

mkdir -p "$DST_REPORT" "$DST_METRICS" "$DST_LOG" "$DST_RESULTS"

# Preserve the exact active Experiment B configuration.
cp -f "$SRC_CONFIG" "$DST_CONFIG"

# Preserve the floorplan and placement reports.
for file in \
  2_floorplan_final.rpt \
  3_global_place.rpt \
  3_resizer.rpt \
  3_detailed_place.rpt
do
  cp -f "$SRC_REPORT/$file" "$DST_REPORT/"
done

# Preserve every placement-stage log and metrics JSON.
for stage in "${stages[@]}"; do
  cp -f "$SRC_LOG/${stage}.log" "$DST_LOG/"
  cp -f "$SRC_LOG/${stage}.json" "$DST_METRICS/"
done

# Preserve the actual detailed-placement database and its constraints.
cp -f "$SRC_RESULTS/3_place.odb" "$DST_RESULTS/"
cp -f "$SRC_RESULTS/3_place.sdc" "$DST_RESULTS/"

# Record what this checkpoint represents.
cat > "$DST_ROOT/README.md" <<EOF2
# Day 19 — Placement Checkpoint: Experiment B

Checkpoint date: $(date -I)

## Selected experiment

- Design: matmul_top
- Platform: Sky130HD
- Experiment: B — 40% core utilization, aspect ratio 1
- Placement density: 0.60
- Configuration: config_expB_util40.mk

## Frozen database

The selected pre-CTS detailed-placement database is:

\`results/day19_expB/3_place.odb\`

Its corresponding timing constraints are:

\`results/day19_expB/3_place.sdc\`

## Selection rationale

Experiment B was retained as the best overall balance among B, G and H.

Reported Experiment B placement metrics:

- Setup slack: +1.45694 ns
- Hold slack: +0.111435 ns
- Fmax: 117.054 MHz
- Weighted global-placement congestion: 0.787743
- Detailed-placement HPWL: 208,319.4 um
- Estimated route wirelength: 217,169 um
- Detailed-placement instance area: 127,883 um^2
- Maximum-slew violations: 0
- Maximum-capacitance violations: 0
- Maximum-fanout violations: 0
- Placement-legality violations: 0

Experiment G had lower weighted congestion, but worse HPWL, setup slack and Fmax.
Experiment H had lower HPWL and estimated route wirelength, but worse setup
slack and Fmax, and 10 maximum-slew violations.

## Checkpoint boundary

This is a **pre-CTS placement checkpoint**. Clock-tree synthesis, routing,
parasitic extraction and post-route timing closure have not yet been evaluated
as part of this checkpoint.

## Archive contents

- The selected placement database and SDC
- The exact Experiment B configuration
- Floorplan and placement reports
- Placement-stage logs and metrics JSON files
- SHA256SUMS for integrity verification
EOF2

# Generate checksums for all archived files, excluding the checksum file itself.
cd "$REPO_ROOT"
find reports/day19_placement_checkpoint/expB results/day19_expB \
  -type f ! -name SHA256SUMS -print0 \
  | sort -z \
  | xargs -0 sha256sum \
  > reports/day19_placement_checkpoint/expB/SHA256SUMS

echo
echo "Day 19 Experiment B checkpoint archived successfully."
echo
echo "=== Archive summary ==="
du -sh reports/day19_placement_checkpoint/expB results/day19_expB
echo
echo "=== Frozen database ==="
ls -lh results/day19_expB/3_place.odb results/day19_expB/3_place.sdc
echo
echo "=== Archived files ==="
find reports/day19_placement_checkpoint/expB results/day19_expB \
  -type f -printf '%p (%s bytes)\n' | sort
