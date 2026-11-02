
module mac_unit #(
    parameter int DATA_WIDTH = 8,
    parameter int ACC_WIDTH  = 19
)(
    input  logic clk,
    input  logic rst_n,

    input  logic clear_acc,
    input  logic mac_en,

    input  logic signed [DATA_WIDTH-1:0] a,
    input  logic signed [DATA_WIDTH-1:0] b,

    output logic signed [ACC_WIDTH-1:0] acc_value,
    output logic signed [ACC_WIDTH-1:0] acc_value_next
);

    // Width of the multiplication result
    localparam int PRODUCT_WIDTH = 2 * DATA_WIDTH;

    // Intermediate multiplication result
    logic signed [PRODUCT_WIDTH-1:0] product;

    // Sign-extended multiplication result
    logic signed [ACC_WIDTH-1:0] product_ext;

    // Signed multiplication
    assign product = a * b;

    // Extend 16-bit product to accumulator width
    assign product_ext = {
        {(ACC_WIDTH-PRODUCT_WIDTH){product[PRODUCT_WIDTH-1]}},
        product
    };

    // Calculate the next accumulator value
    assign acc_value_next = acc_value + product_ext;

    // Accumulator register
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n)
            acc_value <= '0;

        else if (clear_acc)
            acc_value <= '0;

        else if (mac_en)
            acc_value <= acc_value_next;

    end

endmodule
