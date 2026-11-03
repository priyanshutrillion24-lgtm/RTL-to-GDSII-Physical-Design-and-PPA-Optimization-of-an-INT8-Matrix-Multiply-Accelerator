# Day 5 – Functional Verification

## 1. Objective

The objective is to verify the complete 8×8 INT8 matrix-multiply accelerator using a self-checking SystemVerilog testbench and Verilator.

The verification covers input loading, computation sequencing, MAC operation, result storage and output readback.

## 2. Verification Environment

| Component | Description |
|---|---|
| DUT | matmul_top |
| Simulator | Verilator |
| Testbench | tb_matmul_top.sv |
| Operand width | Signed INT8 |
| Accumulator width | Signed 19 bits |
| Matrix dimensions | 8×8 |
| Expected computation latency | 64 cycles |
| Reference model | Software matrix multiplication |

## 3. Test Cases

| Test | Input pattern | Verification objective |
|---|---|---|
| 1 | Identity matrix × arbitrary matrix | Addressing and result ordering |
| 2 | A = -128, B = -128 | Maximum positive accumulation |
| 3 | A = -128, B = 127 | Maximum negative accumulation |
| 4 | Random signed INT8 matrices | General functional correctness |
| 5 | Random signed INT8 matrices | General functional correctness |
| 6 | Random signed INT8 matrices | General functional correctness |

## 4. Reference Model

The testbench independently calculates the expected output:

\[
C_{ij}=\sum_{k=0}^{7}A_{ik}B_{kj}
\]

Every hardware result is compared against the corresponding software reference result.

## 5. Verification Results

Record the actual results after simulation.

| Test | Expected status | Actual status |
|---|---|---|
| Identity matrix | PASS | Pending |
| Maximum positive accumulation | PASS | Pending |
| Maximum negative accumulation | PASS | Pending |
| Random test 1 | PASS | Pending |
| Random test 2 | PASS | Pending |
| Random test 3 | PASS | Pending |

Expected computation latency: 64 cycles per matrix multiplication.

Total expected output comparisons: 384.

## 6. Waveform Analysis

The waveform is stored at:

results/day05_matmul.vcd

Important signals examined:

- Clock and reset.
- Start, busy and done.
- FSM state.
- Row counter and reduction counter.
- MAC enable and accumulator clearing.
- Result storage write enable.
- Output read address and data.

The final accumulation cycle is examined to verify that the updated accumulator value is captured before the accumulators are cleared.

## 7. Functional Limitations and Assumptions

- Both input matrices must be completely loaded before computation starts.
- The design does not contain an input-validity bitmap.
- Matrix storage contents are not reset.
- Result contents are valid only after computation completes.
- The baseline supports a single active matrix multiplication operation at a time.
- The result read interface is combinational.

## 8. Conclusion

The complete accelerator is subjected to directed and random functional verification.

The final verification status will be recorded based on the actual Verilator simulation output, including any failures, debugging changes and waveform observations.
