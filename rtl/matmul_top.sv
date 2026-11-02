
module matmul_top #(
    parameter int DATA_WIDTH  = 8,
    parameter int ACC_WIDTH   = 19,
    parameter int MATRIX_SIZE = 8,
    parameter int INDEX_WIDTH = $clog2(MATRIX_SIZE),
    parameter int ADDR_WIDTH  = $clog2(MATRIX_SIZE*MATRIX_SIZE)
)(
    input logic clk,
    input logic rst_n,

    // Input loading interface
    input logic load_we,
    input logic load_sel,
    input logic [ADDR_WIDTH-1:0] load_addr,
    input logic signed [DATA_WIDTH-1:0] load_data,

    // Computation control
    input logic start,

    // Result read interface
    input logic result_rd_en,
    input logic [ADDR_WIDTH-1:0] result_addr,

    // Status outputs
    output logic busy,
    output logic done,

    // Result output
    output logic signed [ACC_WIDTH-1:0] result_data
);

    // ------------------------------------------
    // Internal controller signals
    // ------------------------------------------

    logic load_enable;
    logic mac_en;
    logic clear_acc;
    logic result_we;

    logic [INDEX_WIDTH-1:0] row_idx;
    logic [INDEX_WIDTH-1:0] k_idx;


    // ------------------------------------------
    // Datapath signals
    // ------------------------------------------

    logic signed [DATA_WIDTH-1:0] a_operand;

    logic [MATRIX_SIZE*DATA_WIDTH-1:0]
        b_operand_bus;

    logic [MATRIX_SIZE*ACC_WIDTH-1:0]
        acc_value_next_bus;


    // ------------------------------------------
    // Controller instance
    // ------------------------------------------

    matrix_controller #(
        .MATRIX_SIZE(MATRIX_SIZE),
.INDEX_WIDTH(INDEX_WIDTH)
    ) u_controller (

        .clk         (clk),
        .rst_n       (rst_n),
        .start       (start),

        .load_enable (load_enable),

        .mac_en      (mac_en),
        .clear_acc   (clear_acc),

        .result_we   (result_we),

        .row_idx     (row_idx),
        .k_idx       (k_idx),

        .busy        (busy),
        .done        (done)

    );


    // ------------------------------------------
    // Matrix storage instance
    // ------------------------------------------

    matrix_storage #(
        .DATA_WIDTH  (DATA_WIDTH),
        .ACC_WIDTH   (ACC_WIDTH),
        .MATRIX_SIZE (MATRIX_SIZE),
.INDEX_WIDTH(INDEX_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH)
    ) u_storage (

        .clk                 (clk),

        .load_enable         (load_enable),
        .load_we             (load_we),
        .load_sel            (load_sel),
        .load_addr           (load_addr),
        .load_data           (load_data),

        .row_idx             (row_idx),
        .k_idx               (k_idx),

        .result_we           (result_we),
        .acc_value_next_bus  (acc_value_next_bus),

        .result_rd_en        (result_rd_en),
        .result_addr         (result_addr),

        .a_operand           (a_operand),
        .b_operand_bus       (b_operand_bus),
        .result_data         (result_data)

    );


    // ------------------------------------------
    // Eight-lane MAC array instance
    // ------------------------------------------

    mac_array #(
        .DATA_WIDTH (DATA_WIDTH),
        .ACC_WIDTH  (ACC_WIDTH),
        .LANES      (MATRIX_SIZE)
    ) u_mac_array (

        .clk                 (clk),
        .rst_n               (rst_n),

        .clear_acc           (clear_acc),
        .mac_en              (mac_en),

        .a                   (a_operand),
        .b_bus               (b_operand_bus),

        // Current accumulator values are not
        // required by the top-level controller.
        .acc_value_bus       (),

        // Final accumulation values are used
        // by the result storage.
        .acc_value_next_bus  (acc_value_next_bus)

    );

endmodule
