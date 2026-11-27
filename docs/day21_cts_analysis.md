# Day 21 — Clock Tree Synthesis Analysis

**Date:** 27 November 2026
**Design:** `matmul_top`
**Platform:** Sky130HD
**Selected placement:** Experiment B
**Clock:** `core_clk`, 10 ns period (100 MHz target)

## 1. Objective

Run CTS on the frozen Day 19 Experiment B placement checkpoint and analyze
the changes in timing, clock latency, clock skew, area and hold behavior.

The CTS flow completed and generated the post-CTS database and SDC.
This report uses the installed ORFS CTS log, final CTS report and metrics JSON.

## 2. Starting checkpoint verification

Before CTS, the following files were compared against the frozen Day 19
archive:

- `3_place.odb`
- `3_place.sdc`

Both files matched the Day 19 checkpoint exactly.

No previous CTS databases, logs or reports were present before this run.

## 3. Clock-tree construction

TritonCTS successfully constructed an H-tree for `core_clk`.

| Metric | Result |
|---|---:|
| Clock nets discovered | 1 |
| Original clock sinks | 2,401 |
| Sinks after clustering | 226 |
| Clock buffers created | 267 |
| Clock nets created | 267 |
| Leaf buffers | 226 |
| Dummy loads inserted | 199 |
| Maximum clock-tree level reported | 5 |
| Maximum sinks per cluster | 16 |
| Selected cluster diameter | 153 um |
| Average sink wire length | 858.01 um |
| Clock buffer cell | `sky130_fd_sc_hd__clkbuf_16` |

The CTS log reports that the root, sink and characterization buffer type
was `sky130_fd_sc_hd__clkbuf_16`.

Sink clustering was enabled. The tool selected a clustering size of 16
and a maximum cluster diameter of 153 um for this run.

The clock-tree construction completed successfully.

## 4. Pre-CTS versus post-CTS comparison

The pre-CTS values are from the Day 19 Experiment B detailed-placement
metrics. The post-CTS values are from `4_1_cts.json`.

| Metric | Pre-CTS | Post-CTS |
|---|---:|---:|
| Setup worst slack | +1.45694 ns | +1.42995 ns |
| Hold worst slack | +0.111435 ns | +0.0305196 ns |
| Fmax | 117.054 MHz | 116.685 MHz |
| Instance area | 127,883 um^2 | 136,400 um^2 |
| Utilization | 44.7613% | 47.7424% |
| Setup TNS | 0 ns | 0 ns |
| Hold TNS | 0 ns | 0 ns |

### 4.1 Observed changes

- Setup slack decreased by approximately 26.99 ps.
- Hold slack decreased by approximately 80.92 ps.
- Reported Fmax decreased by approximately 0.369 MHz.
- Instance area increased by 8,517 um^2, approximately 6.66%.
- Setup and hold TNS remained zero after CTS timing repair.

The area increase is the total observed change between detailed placement
and the final CTS stage. It should not be attributed entirely to clock
buffers without separately measuring the area contribution of each cell
category.

These are placement-based parasitic estimates, not extracted post-route
timing results.

## 5. Clock insertion latency

The standalone `report_clock_latency` command was run on the final CTS
database with propagated clocks and placement-based parasitic estimation.

| Clock edge | Minimum network latency | Maximum network latency | Spread |
|---|---:|---:|---:|
| Rising | 0.8320 ns | 0.9203 ns | 0.0883 ns |
| Falling | 0.8038 ns | 0.8648 ns | 0.0610 ns |

These values represent the range of network latency across the reported
clock sinks. They are not one universal insertion-delay value for every
sink.

An example path to
`u_storage.matrix_a[58][1]/CLK` showed approximately 0.89 ns of clock
network latency through four clock buffer stages.

## 6. Clock skew analysis

The CTS JSON reported:

| Metric | Value |
|---|---:|
| Setup clock-skew metric | 0.288273 ns |
| Hold clock-skew metric | 0.119925 ns |

The detailed `report_clock_skew` output includes clock uncertainty.
Therefore, the reported setup and hold skew quantities must not be
mistaken for pure physical clock-arrival differences.

### 6.1 Setup example

The report showed:

- Source clock latency: 0.9203 ns
- Target clock latency: 0.8320 ns
- Setup uncertainty: 0.2000 ns
- CRPR: 0.0000 ns
- Reported setup-skew quantity: 0.2883 ns

Using capture arrival minus launch arrival:

T_skew = 0.8320 - 0.9203 = -0.0883 ns

The physical skew for this selected setup path is approximately -88.3 ps.
The report's 0.2883 ns quantity also includes the 200 ps setup uncertainty.

### 6.2 Hold example

The report showed:

- Source clock latency: 0.8320 ns
- Target clock latency: 0.9019 ns
- Hold uncertainty: 0.0500 ns
- CRPR: 0.0000 ns
- Reported hold-skew quantity: -0.1199 ns

Using capture arrival minus launch arrival:

T_skew = 0.9019 - 0.8320 = +0.0699 ns

The physical skew for this selected hold path is approximately +69.9 ps.
The report's hold-skew quantity includes the 50 ps hold uncertainty and
uses the tool's hold-report sign convention.

The setup and hold examples are different launch/capture pairs. Their
physical skew values should not be treated as one global clock skew.

## 7. CTS timing repair and hold observations

Before timing repair, the CTS log reported:

- No setup violations found.
- 272 endpoints with hold violations.
- Initial hold-repair WNS: -0.765 ns.
- Initial hold-repair TNS: -51.126 ns.

The repair process inserted 8 hold buffers.

At the end of the repair table:
- WNS was +0.026 ns.
- TNS was 0.000 ns.

The final CTS JSON separately reported hold worst slack of +0.0305196 ns
and hold TNS of zero.

The small difference between the repair-table WNS and the final JSON
worst-slack metric is retained as reported; the values should not be
silently substituted for one another.

The timing report includes an input-to-register minimum-delay path from
`load_data[1]` to `u_storage.matrix_a[58][1]/D`, with approximately
+0.03 ns slack after repair.

**Important classification note:** the CTS log's 272 count is a count of
endpoints reported by the repair process as having hold violations.
At least one example endpoint is an asynchronous reset pin with a
removal check. These 272 endpoints must not all be described as ordinary
register-to-register data hold violations without further classification.
This is a topic for the Day 22 hold study.

The repair output passed the LEC test. Detailed placement completed with
zero placement violations.

## 8. Final CTS status

| Check | Result |
|---|---|
| CTS clock-tree construction | Completed |
| CTS database generated | Yes |
| CTS SDC generated | Yes |
| Setup TNS after repair | 0 |
| Hold TNS after repair | 0 |
| Setup violation count | 0 |
| Hold violation count | 0 |
| Maximum slew violation count | 0 |
| Maximum capacitance violation count | 0 |
| Maximum fanout violation count | 0 |
| Placement legality violations | 0 |
| Repair LEC | Passed |

A warning was printed stating that the decap master
`sky130_ef_sc_hd__decap_12` has signal pins but no Liberty cell. It did not
prevent CTS from completing or writing its output database.

## 9. Reporting-tool observation

A separate OpenROAD session loaded the completed CTS database and ran
`report_clock_latency` and `report_clock_skew` successfully.

In that independent session, `report_cts` returned zero roots, buffers,
subnets and sinks. This standalone summary was not used as the clock-tree
count because the session loaded the database but did not execute CTS.
The original CTS execution log is the authoritative source for the
267 clock buffers and 2,401 sinks.

## 10. Conclusions

1. CTS constructed an H-tree for the 2,401 clock sinks using 267 clock
   buffers of type `sky130_fd_sc_hd__clkbuf_16`.
2. Rising-edge network latency ranged from 0.8320 ns to 0.9203 ns.
3. The reported skew metrics include clock uncertainty; physical
   capture-minus-launch skew must be calculated from the selected path's
   clock arrival times.
4. CTS timing repair inserted 8 hold buffers.
5. Setup and hold TNS were zero after repair, with positive worst slack.
6. Instance area increased by approximately 6.66% from detailed placement
   to the CTS result.
7. The implementation is a post-CTS, placement-parasitic result. It is
   not a routed or extracted signoff result.

## 11. Next stage

Day 22 will investigate the hold endpoints reported during CTS timing
repair. The study will distinguish ordinary data hold checks from
asynchronous reset recovery/removal checks, inspect representative paths,
and evaluate the effect of the inserted hold buffers.

## 12. Evidence files

The supporting CTS database, SDC, log, metrics JSON and final report are
archived under:

- `reports/day21_cts_analysis/expB/`
- `results/day21_expB/`
