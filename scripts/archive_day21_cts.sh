#!/usr/bin/env bash
set -euo pipefail

FLOW_HOME="${HOME}/eda/OpenROAD-flow-scripts/flow"
REPO_ROOT="${HOME}/projects/int8-matmul-physical-design"
DESIGN="int8_matmul_expB_util40"

SRC_BASE="${FLOW_HOME}/results/sky130hd/${DESIGN}/base"
SRC_LOG="${FLOW_HOME}/logs/sky130hd/${DESIGN}/base"
SRC_REPORT="${FLOW_HOME}/reports/sky130hd/${DESIGN}/base"
SRC_CONFIG="${FLOW_HOME}/designs/sky130hd/int8_matmul/config_expB_util40.mk"
SRC_LATENCY_TCL="${FLOW_HOME}/day21_clock_latency.tcl"

DST_ROOT="${REPO_ROOT}/reports/day21_cts_analysis/expB"
DST_LOG="${DST_ROOT}/logs"
DST_METRICS="${DST_ROOT}/metrics"
DST_REPORT="${DST_ROOT}/reports"
DST_RESULTS="${REPO_ROOT}/results/day21_expB"

required_files=(
  "$SRC_CONFIG"
  "$SRC_LATENCY_TCL"
  "$SRC_BASE/4_cts.odb"
  "$SRC_BASE/4_cts.sdc"
  "$SRC_LOG/4_1_cts.log"
  "$SRC_LOG/4_1_cts.json"
  "$SRC_REPORT/4_cts_final.rpt"
)

for file in "${required_files[@]}"; do
  if [[ ! -s "$file" ]]; then
    echo "ERROR: Required artifact missing or empty: $file" >&2
    exit 1
  fi
done

mkdir -p "$DST_LOG" "$DST_METRICS" "$DST_REPORT" \
  "$DST_RESULTS" "$REPO_ROOT/scripts"

cp -f "$SRC_CONFIG" "$DST_ROOT/config_expB_util40.mk"
cp -f "$SRC_LOG/4_1_cts.log" "$DST_LOG/"
cp -f "$SRC_LOG/4_1_cts.json" "$DST_METRICS/"
cp -f "$SRC_REPORT/4_cts_final.rpt" "$DST_REPORT/"
cp -f "$SRC_BASE/4_cts.sdc" "$DST_RESULTS/"
cp -f "$SRC_BASE/4_cts.odb" "$DST_RESULTS/"

# Preserve the additional repair/LEC logs when present.
for file in 4_rsz_lec.log 4_rsz_lec_check.log; do
  if [[ -s "$SRC_LOG/$file" ]]; then
    cp -f "$SRC_LOG/$file" "$DST_LOG/"
  fi
done

# Preserve the reporting Tcl, excluding report_cts because its summary
# was not populated in the independent reporting session.
cp -f "$SRC_LATENCY_TCL" "$REPO_ROOT/scripts/day21_clock_latency.tcl"
sed -i \
  -e '/CLOCK TREE SUMMARY/d' \
  -e '/^report_cts$/d' \
  "$REPO_ROOT/scripts/day21_clock_latency.tcl"

cat > "$DST_ROOT/README.md" <<'EOF2'
# Day 21 CTS archive — Experiment B

This archive contains the post-CTS result for the frozen Day 19
Experiment B placement.

Contents:
- Final CTS database and corresponding SDC
- Exact Experiment B configuration
- CTS execution log and metrics JSON
- Final CTS report
- Repair/LEC logs, when present

The CTS database is retained locally and excluded from Git.
Its checksum is included in SHA256SUMS.

Clock-latency and clock-skew reporting is reproducible using:
scripts/day21_clock_latency.tcl

Run the reporting script from the ORFS flow directory using:
util/docker_shell openroad -exit /work/day21_clock_latency.tcl

The report uses placement-based parasitic estimation. These results are
not extracted post-route signoff timing.
EOF2

# Generate checksums for all archived files, excluding the manifest itself.
cd "$REPO_ROOT"
find reports/day21_cts_analysis/expB results/day21_expB \
  -type f ! -name SHA256SUMS -print0 \
  | sort -z \
  | xargs -0 sha256sum \
  > reports/day21_cts_analysis/expB/SHA256SUMS

echo "Day 21 CTS archive created."
echo
echo "=== Archive sizes ==="
du -sh reports/day21_cts_analysis/expB results/day21_expB
echo
echo "=== Frozen CTS database and SDC ==="
ls -lh results/day21_expB/4_cts.odb results/day21_expB/4_cts.sdc
echo
echo "=== Archived files ==="
find reports/day21_cts_analysis/expB results/day21_expB \
  -type f -printf '%p (%s bytes)\n' | sort
