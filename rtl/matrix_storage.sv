
module matrix_storage #(
    parameter int DATA_WIDTH  = 8,
    parameter int ACC_WIDTH   = 19,
    parameter int MATRIX_SIZE = 8,
    parameter int INDEX_WIDTH = $clog2(MATRIX_SIZE),
    parameter int ADDR_WIDTH  = $clog2(MATRIX_SIZE*MATRIX_SIZE)
)(
    input logic clk,

    // Matrix loading interface
    input logic load_enable,
    input logic load_we,
    input logic load_sel,
    input logic [ADDR_WIDTH-1:0] load_addr,
    input logic signed [DATA_WIDTH-1:0] load_data,

    // Current computation indices
    input logic [INDEX_WIDTH-1:0] row_idx,
    input logic [INDEX_WIDTH-1:0] k_idx,

    // Result storage write interface
    input logic result_we,
    input logic [MATRIX_SIZE*ACC_WIDTH-1:0]
          acc_value_next_bus,

    // Result read interface
    input logic result_rd_en,
    input logic [ADDR_WIDTH-1:0] result_addr,

    // Datapath outputs
    output logic signed [DATA_WIDTH-1:0] a_operand,
    output logic [MATRIX_SIZE*DATA_WIDTH-1:0]
          b_operand_bus,
    output logic signed [ACC_WIDTH-1:0] result_data
);

    // Matrix A storage
    logic signed [DATA_WIDTH-1:0]
        matrix_a [0:MATRIX_SIZE*MATRIX_SIZE-1];

    // Matrix B storage
    logic signed [DATA_WIDTH-1:0]
        matrix_b [0:MATRIX_SIZE*MATRIX_SIZE-1];

    // Result matrix storage
    logic signed [ACC_WIDTH-1:0]
        result_mem [0:MATRIX_SIZE*MATRIX_SIZE-1];


    // ------------------------------------------
    // Storage write operations
    // ------------------------------------------
    always_ff @(posedge clk) begin

        // Input matrix loading
        if (load_enable && load_we) begin

            if (load_sel == 1'b0)
                matrix_a[load_addr] <= load_data;

            else
                matrix_b[load_addr] <= load_data;

        end

        // Store all eight results when one output
        // matrix row has completed.
        if (result_we) begin

            for (int lane = 0; lane < MATRIX_SIZE; lane++) begin

                result_mem[(int'(row_idx) * MATRIX_SIZE) + lane] <=
    $signed(
        acc_value_next_bus[
            lane*ACC_WIDTH +: ACC_WIDTH
        ]
    );

            end

        end

    end


    // ------------------------------------------
    // Combinational operand selection
    // ------------------------------------------
    always_comb begin

        // Select A[row_idx][k_idx]
        a_operand =
    matrix_a[(int'(row_idx) * MATRIX_SIZE) + int'(k_idx)];

        // Select eight B operands:
        // B[k_idx][0], B[k_idx][1], ... B[k_idx][7]
        b_operand_bus = '0;

        for (int lane = 0; lane < MATRIX_SIZE; lane++) begin

            b_operand_bus[
    lane*DATA_WIDTH +: DATA_WIDTH
] = matrix_b[(int'(k_idx) * MATRIX_SIZE) + lane];

        end

        // Result read interface
        if (result_rd_en)
            result_data = result_mem[result_addr];

        else
            result_data = '0;

    end

endmodule
