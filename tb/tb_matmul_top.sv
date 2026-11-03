
module tb_matmul_top;

    localparam int DATA_WIDTH  = 8;
    localparam int ACC_WIDTH   = 19;
    localparam int MATRIX_SIZE = 8;
    localparam int ADDR_WIDTH  = 6;

    // Clock and reset
    logic clk;
    logic rst_n;

    // Input loading interface
    logic load_we;
    logic load_sel;
    logic [ADDR_WIDTH-1:0] load_addr;
    logic signed [DATA_WIDTH-1:0] load_data;

    // Computation control
    logic start;

    // Result read interface
    logic result_rd_en;
    logic [ADDR_WIDTH-1:0] result_addr;

    // Status signals
    logic busy;
    logic done;

    // Result output
    logic signed [ACC_WIDTH-1:0] result_data;

    // Reference matrices
    logic signed [7:0] a_ref [0:63];
    logic signed [7:0] b_ref [0:63];

    // Software reference results
    integer expected_mem [0:63];

    // Testbench variables
    integer random_seed;
    


    // ------------------------------------------
    // Clock generation: 10 ns period
    // ------------------------------------------

    initial clk = 1'b0;
    always #5 clk <= ~clk;


    // ------------------------------------------
    // Device under test
    // ------------------------------------------

    matmul_top #(
        .DATA_WIDTH  (DATA_WIDTH),
        .ACC_WIDTH   (ACC_WIDTH),
        .MATRIX_SIZE (MATRIX_SIZE),
        .ADDR_WIDTH  (ADDR_WIDTH)
    ) dut (

        .clk          (clk),
        .rst_n        (rst_n),

        .load_we      (load_we),
        .load_sel     (load_sel),
        .load_addr    (load_addr),
        .load_data    (load_data),

        .start        (start),

        .result_rd_en (result_rd_en),
        .result_addr  (result_addr),

        .busy         (busy),
        .done         (done),

        .result_data  (result_data)

    );


    // ------------------------------------------
    // Task 1: Generate input matrices
    // ------------------------------------------

    task automatic generate_matrices(input integer test_id);

        integer row;
        integer col;

        begin

            for (integer idx = 0; idx < 64; idx++) begin

                row = idx / MATRIX_SIZE;
                col = idx % MATRIX_SIZE;

                case (test_id)

                    // Test 0: Identity matrix A
                    0: begin

                        if (row == col)
                            a_ref[idx] = 8'sd1;
                        else
                            a_ref[idx] = 8'sd0;

                        // Deterministic signed values
                        b_ref[idx] = $signed(
                            8'(((idx * 29) % 256) - 128)
                        );

                    end


                    // Test 1: Maximum positive accumulation
                    1: begin

                        a_ref[idx] = 8'sh80;
                        b_ref[idx] = 8'sh80;

                    end


                    // Test 2: Maximum negative accumulation
                    2: begin

                        a_ref[idx] = 8'sh80;
                        b_ref[idx] =  8'sd127;

                    end


                    // Tests 3, 4 and 5: Random matrices
                    default: begin

                        a_ref[idx] = $signed(
                            8'($urandom(random_seed))
                        );

                        b_ref[idx] = $signed(
                            8'($urandom(random_seed))
                        );

                    end

                endcase

            end

        end

    endtask


    // ------------------------------------------
    // Task 2: Calculate software reference result
    // ------------------------------------------

    task automatic calculate_reference;

        integer total;

        begin

            for (integer row = 0;
                 row < MATRIX_SIZE;
                 row++) begin

                for (integer col = 0;
                     col < MATRIX_SIZE;
                     col++) begin

                    total = 0;

                    for (integer k = 0;
                         k < MATRIX_SIZE;
                         k++) begin

                        total = total +
                            (int'(a_ref[row*MATRIX_SIZE+k]) *
                             int'(b_ref[k*MATRIX_SIZE+col]));

                    end

                    expected_mem[row*MATRIX_SIZE+col] = total;

                end

            end

        end

    endtask


    // ------------------------------------------
    // Task 3: Load matrices into the accelerator
    // ------------------------------------------

    task automatic load_matrices;

        begin

            // Load matrix A
            for (integer idx = 0; idx < 64; idx++) begin

                @(negedge clk);

                load_we   = 1'b1;
                load_sel  = 1'b0;
                load_addr = ADDR_WIDTH'(idx);
                load_data = a_ref[idx];

                @(posedge clk);
                #1;

            end


            // Load matrix B
            for (integer idx = 0; idx < 64; idx++) begin

                @(negedge clk);

                load_we   = 1'b1;
                load_sel  = 1'b1;
                load_addr = ADDR_WIDTH'(idx);
                load_data = b_ref[idx];

                @(posedge clk);
                #1;

            end


            // Disable loading
            @(negedge clk);

            load_we   = 1'b0;
            load_sel  = 1'b0;
            load_addr = '0;
            load_data = '0;

        end

    endtask


    // ------------------------------------------
    // Task 4: Execute one complete test
    // ------------------------------------------

    task automatic run_test(input integer test_id);

        integer cycles;
        integer errors;

        begin

            $display("");
            $display("====================================");
            $display("Starting test case %0d", test_id);
            $display("====================================");


            // Generate matrices
            generate_matrices(test_id);

            // Calculate independent software reference
            calculate_reference();

            // Load both matrices
            load_matrices();


            // Apply start pulse
            @(negedge clk);
            start = 1'b1;

            @(posedge clk);
            #1;

            @(negedge clk);
            start = 1'b0;


            // Wait for completion and count compute cycles
            cycles = 0;

            while (done !== 1'b1) begin

                @(posedge clk);

                if (busy === 1'b1)
                    cycles = cycles + 1;

            end


            // Check computation latency
            if (cycles != 64) begin

                $fatal(1,
                    "FAIL: Expected 64 compute cycles, got %0d",
                    cycles
                );

            end


            // Confirm DONE state was reached
            if (done !== 1'b1)
                $fatal(1, "FAIL: DONE signal not asserted");


            // DONE must last for one clock cycle
            #1;

            if (done !== 1'b0)
                $fatal(1, "FAIL: DONE pulse was not one cycle");


            // ----------------------------------
            // Read and verify all 64 results
            // ----------------------------------

            errors = 0;

            @(negedge clk);

            result_rd_en = 1'b1;

            for (integer idx = 0; idx < 64; idx++) begin

                result_addr = ADDR_WIDTH'(idx);

                // Allow combinational read data to settle
                #1;

                if (int'(result_data) != expected_mem[idx]) begin

                    errors = errors + 1;

                    $display(
                        "MISMATCH: Test=%0d Address=%0d Expected=%0d Actual=%0d",
                        test_id,
                        idx,
                        expected_mem[idx],
                        $signed(result_data)
                    );

                end

                @(negedge clk);

            end


            result_rd_en = 1'b0;
            result_addr  = '0;


            // Final verification status
            if (errors != 0) begin

                $fatal(1,
                    "TEST %0d FAILED: %0d mismatches",
                    test_id,
                    errors
                );

            end


            $display("TEST %0d PASSED", test_id);
            $display("Computation cycles: %0d", cycles);
            $display("All 64 output elements verified.");

        end

    endtask


    // ------------------------------------------
    // Main test sequence
    // ------------------------------------------

    initial begin

        // Initialize all input signals
        rst_n        = 1'b0;

        load_we      = 1'b0;
        load_sel     = 1'b0;
        load_addr    = '0;
        load_data    = '0;

        start        = 1'b0;

        result_rd_en = 1'b0;
        result_addr  = '0;

        random_seed  = 32'h1BAD_B002;


        // Apply reset
        repeat (3) @(posedge clk);

        @(negedge clk);
        rst_n = 1'b1;


        // Run directed and random tests
        run_test(0);
        run_test(1);
        run_test(2);

        run_test(3);
        run_test(4);
        run_test(5);


        // Final result
        $display("");
        $display("====================================");
        $display("ALL FUNCTIONAL TESTS PASSED");
        $display("Total test cases: 6");
        $display("Output elements checked: 384");
        $display("====================================");

        $finish;

    end


    // ------------------------------------------
    // Waveform generation
    // ------------------------------------------

    initial begin

        $dumpfile("results/day05_matmul.vcd");
        $dumpvars(0, tb_matmul_top);

    end


endmodule
