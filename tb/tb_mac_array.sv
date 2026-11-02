
module tb_mac_array;

    localparam int DATA_WIDTH = 8;
    localparam int ACC_WIDTH  = 19;
    localparam int LANES      = 8;

    logic clk;
    logic rst_n;
    logic clear_acc;
    logic mac_en;

    logic signed [DATA_WIDTH-1:0] a;
    logic [LANES*DATA_WIDTH-1:0] b_bus;

    logic [LANES*ACC_WIDTH-1:0] acc_value_bus;
    logic [LANES*ACC_WIDTH-1:0] acc_value_next_bus;

    logic signed [ACC_WIDTH-1:0] got;
    logic signed [ACC_WIDTH-1:0] expected;

    // Clock generation: 10 ns period
    initial clk = 0;
    always #5 clk <= ~clk;

    // Instantiate MAC array
    mac_array #(
        .DATA_WIDTH(DATA_WIDTH),
        .ACC_WIDTH(ACC_WIDTH),
        .LANES(LANES)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .clear_acc(clear_acc),
        .mac_en(mac_en),
        .a(a),
        .b_bus(b_bus),
        .acc_value_bus(acc_value_bus),
        .acc_value_next_bus(acc_value_next_bus)
    );

    initial begin

        // Initial values
        rst_n    = 0;
        clear_acc = 0;
        mac_en    = 0;
        a         = 0;
        b_bus     = '0;

        // Apply reset
        repeat (2) @(posedge clk);

        @(negedge clk);
        rst_n = 1;

        // Calculate one output row using all 8 MAC lanes
        for (int k = 0; k < 8; k++) begin

            @(negedge clk);

            // A = [-1, 2, -3, 4, -5, 6, -7, 8]
            case (k)
                0: a = -8'sd1;
                1: a =  8'sd2;
                2: a = -8'sd3;
                3: a =  8'sd4;
                4: a = -8'sd5;
                5: a =  8'sd6;
                6: a = -8'sd7;
                7: a =  8'sd8;
            endcase

            // Each lane receives a different B value
            for (int lane = 0; lane < LANES; lane++) begin
                b_bus[lane*DATA_WIDTH +: DATA_WIDTH] = DATA_WIDTH'(lane + 1);
            end

            mac_en = 1;

            // Clear accumulator on the final term.
            // The completed sum remains available through
            // acc_value_next_bus for result capture.
            clear_acc = (k == 7);

            #1;

            // Verify the completed dot product before
            // the final accumulation edge.
            if (k == 7) begin

                for (int lane = 0; lane < LANES; lane++) begin

                    got = $signed(
                        acc_value_next_bus[
                            lane*ACC_WIDTH +: ACC_WIDTH
                        ]
                    );

                    // Sum of A elements = 4
                    // Each lane's B operand = lane + 1
                    expected = $signed(ACC_WIDTH'(4 * (lane + 1)));

                    if (got !== expected) begin
                        $fatal(1,
                            "FAIL: Lane %0d: Expected %0d, Got %0d",
                            lane, expected, got
                        );
                    end

                end

            end

            @(posedge clk);
            #1;

        end

        // Accumulators should be cleared after the
        // final accumulation cycle.
        mac_en = 0;
        clear_acc = 0;

        if (acc_value_bus !== '0)
            $fatal(1, "FAIL: Accumulators were not cleared");

        $display("----------------------------------");
        $display("MAC ARRAY TEST PASSED");
        $display("All 8 lanes produced correct results");
        $display("----------------------------------");

        $finish;

    end

endmodule
