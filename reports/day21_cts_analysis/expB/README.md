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
