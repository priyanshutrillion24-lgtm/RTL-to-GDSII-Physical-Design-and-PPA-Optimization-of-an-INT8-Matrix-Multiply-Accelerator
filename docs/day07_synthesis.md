## 4. Synthesis QoR Baseline

The following results were obtained from the Yosys synthesis statistics report using the Sky130HD standard-cell library.

| Metric | Measured result |
|---|---:|
| Total standard-cell count | 6,041 |
| Sequential cell count | 2,401 |
| Combinational cell count | 3,640 |
| Sequential cell area | 71,294.6272 µm² |
| Combinational cell area | 43,838.2944 µm² |
| Total mapped cell area | 115,132.9216 µm² |
| Synthesis-check problems | 0 |
| Inferred SRAM macros | 0 |

### 4.1 Area Distribution

Sequential area:

\[
A_{seq}=71294.6272\;\mu m^2
\]

Combinational area:

\[
A_{comb}=43838.2944\;\mu m^2
\]

Total mapped cell area:

\[
A_{total}=A_{seq}+A_{comb}
\]

\[
A_{total}=115132.9216\;\mu m^2
\]

Sequential area accounts for 61.92% of the total mapped standard-cell area, while combinational area accounts for 38.08%.

### 4.2 Sequential Cell Analysis

The synthesis report contains:

| Cell | Count |
|---|---:|
| sky130_fd_sc_hd__dfrtp_1 | 160 |
| sky130_fd_sc_hd__dfstp_2 | 1 |
| sky130_fd_sc_hd__edfxtp_1 | 2,240 |

The 2,240 enable flip-flops correspond numerically to the combined storage capacity of matrix A, matrix B and the result matrix.

### 4.3 Combinational Cell Analysis

Some notable mapped combinational cells are:

| Cell | Count |
|---|---:|
| sky130_fd_sc_hd__fa_1 | 680 |
| sky130_fd_sc_hd__ha_1 | 348 |
| sky130_fd_sc_hd__mux4_2 | 656 |
| sky130_fd_sc_hd__mux2i_1 | 128 |
| sky130_fd_sc_hd__nor2_1 | 628 |

The full-adder and half-adder cells are associated with the arithmetic implementation. The multiplexer count highlights the importance of operand and result selection logic.

### 4.4 Storage Implementation

The Yosys report shows no remaining memory objects after technology mapping.

The synthesis log confirms that the MEMORY_MAP pass converted memories into logic and flip-flops.

The three matrix storage arrays were therefore implemented using standard-cell storage rather than dedicated SRAM macros.

### 4.5 Synthesis Checks and Warnings

The synthesis check report states:

```text
Checking module matmul_top...
Found and reported 0 problems.
```

OpenROAD reported a library consistency warning:

```text
Warning: master sky130_ef_sc_hd__decap_12 has signal pins
but no liberty cell
```

A search of the mapped Verilog netlist did not identify an instance of this cell. The warning is retained for documentation and library review.

### 4.6 Conclusion

The complete INT8 matrix-multiply accelerator was successfully synthesized using the Sky130HD standard-cell library.

The mapped design contains 6,041 standard-cell instances with a total mapped cell area of 115,132.9216 µm².

Sequential elements account for 61.92% of the total area, primarily reflecting the register-based storage architecture.

The synthesis reports show that the matrix storage was mapped into enable flip-flops, while the arithmetic operations and operand selection logic were mapped into standard combinational cells.

These measurements establish the initial synthesis baseline for subsequent pre-layout timing analysis, floorplanning, placement and PPA optimization.
