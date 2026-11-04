# Day 8 – Pre-layout Static Timing Analysis

## 1. Objective

Perform pre-layout static timing analysis of the INT8 matrix multiplication accelerator using OpenROAD/OpenSTA and the Sky130HD typical timing library.

The objective was to identify critical timing paths, evaluate setup and hold timing, investigate high-fanout control signals, and isolate the MAC arithmetic datapath.

## 2. Timing Environment

- Technology: Sky130HD
- Library corner: TT, 25°C, 1.8 V
- Clock: core_clk
- Clock period: 10 ns
- Target frequency: 100 MHz
- Setup uncertainty: 0.2 ns
- Hold uncertainty: 0.05 ns

## 3. Initial STA Results

| Metric | Result |
|---|---:|
| Worst setup slack | -7.8013 ns |
| Worst hold/removal slack | -0.2004 ns |
| Total negative slack | -3457.82 ns |
| Clock period | 10 ns |

The initial worst setup path started at rst_n and ended at the enable pin of a result-storage flip-flop.

## 4. High-fanout Investigation

The critical NOR4 output had:

- Fanout: 152
- Output capacitance: 0.518 pF
- Output slew: 19.0182 ns
- Maximum transition constraint: 0.5 ns
- Cell delay: 14.3389 ns

The result-storage control network drives 152 result bits per output row (8 lanes × 19 bits).

The input load_data bits also have high fanout because they are distributed across the two 8-bit, 8×8 input matrices.

## 5. Isolated Register-to-register Datapath Results

### MAC accumulator

- Startpoint: u_controller.k_idx[2]
- Endpoint: u_mac_array.gen_mac[5].u_mac.acc_value[18]
- Data arrival: 7.0130 ns
- Data required: 9.7482 ns
- Setup slack: +2.7352 ns
- Status: MET

### Result-storage data path

- Startpoint: u_controller.k_idx[2]
- Endpoint: u_storage.result_mem[17][17]
- Data arrival: 6.8168 ns
- Data required: 9.5515 ns
- Setup slack: +2.7347 ns
- Status: MET

The isolated paths traverse operand-selection logic and arithmetic cells, including full adders and half adders.

## 6. Hold and Asynchronous Reset Analysis

No ordinary synchronous minimum-delay hold paths were reported in the detailed hold-violation section.

An asynchronous removal violation of approximately -0.2004 ns was reported on the reset network.

The design uses asynchronous active-low reset in the matrix controller and MAC units. Reset deassertion synchronization remains a potential design improvement.

## 7. Conclusions

1. The isolated register-to-register MAC accumulator data paths meet the 10 ns clock target in the synthesis-stage timing analysis.
2. The result-storage data paths also meet the target in the analyzed path set.
3. The major initial timing problem is the high-fanout result-storage enable network.
4. The NOR4 output driving 152 loads exhibits severe transition and capacitance violations.
5. Asynchronous reset recovery/removal checks need further investigation.
6. Further timing evaluation is required after floorplanning, placement, clock-tree synthesis, and routing.

## 8. Reports and Scripts

Scripts are stored in `scripts/sta/`.

Reports are stored in `reports/day08_sta/`.

All timing values represent preliminary synthesis-stage analysis and must not be treated as final post-route timing results.
