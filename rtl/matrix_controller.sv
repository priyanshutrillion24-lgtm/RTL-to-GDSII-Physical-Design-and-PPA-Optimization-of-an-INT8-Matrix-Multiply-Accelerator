
module matrix_controller #(
    parameter int MATRIX_SIZE = 8,
    parameter int INDEX_WIDTH = $clog2(MATRIX_SIZE)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic start,

    // Matrix loading control
    output logic load_enable,

    // MAC control
    output logic mac_en,
    output logic clear_acc,

    // Result storage control
    output logic result_we,

    // Computation indices
    output logic [INDEX_WIDTH-1:0] row_idx,
    output logic [INDEX_WIDTH-1:0] k_idx,

    // Status signals
    output logic busy,
    output logic done
);

    // FSM state declaration
    typedef enum logic [1:0] {
        IDLE,
        COMPUTE,
        DONE
    } state_t;

    state_t state;

    // Last valid row and K index
    localparam logic [INDEX_WIDTH-1:0] LAST_INDEX =
        INDEX_WIDTH'(MATRIX_SIZE - 1);

    // State and counter registers
    always_ff @(posedge clk or negedge rst_n) begin

        if (!rst_n) begin
            state   <= IDLE;
            row_idx <= '0;
            k_idx   <= '0;
        end

        else begin

            case (state)

                // --------------------------------
                // IDLE STATE
                // --------------------------------
                IDLE: begin

                    row_idx <= '0;
                    k_idx   <= '0;

                    if (start)
                        state <= COMPUTE;

                end

                // --------------------------------
                // COMPUTE STATE
                // --------------------------------
                COMPUTE: begin

                    if (k_idx == LAST_INDEX) begin

                        // Current output row is complete
                        k_idx <= '0;

                        if (row_idx == LAST_INDEX) begin

                            // Entire matrix multiplication complete
                            state <= DONE;

                        end

                        else begin

                            // Move to the next output row
                            row_idx <= row_idx + 1'b1;

                        end

                    end

                    else begin

                        // Move to the next multiplication term
                        k_idx <= k_idx + 1'b1;

                    end

                end

                // --------------------------------
                // DONE STATE
                // --------------------------------
                DONE: begin

                    state   <= IDLE;
                    row_idx <= '0;
                    k_idx   <= '0;

                end

                default: begin

                    state   <= IDLE;
                    row_idx <= '0;
                    k_idx   <= '0;

                end

            endcase

        end

    end

    // Combinational control signal generation
    always_comb begin

        // Default values
        load_enable = 1'b0;
        mac_en      = 1'b0;
        clear_acc   = 1'b0;
        result_we   = 1'b0;
        busy        = 1'b0;
        done        = 1'b0;

        if (rst_n) begin

            // Loading is allowed only in IDLE
            // and when start is not asserted.
            load_enable = (state == IDLE) && !start;

            // Enable MAC units during computation
            mac_en = (state == COMPUTE);

            // Clear accumulators when a new operation
            // starts or after an output row is completed.
            clear_acc =
                ((state == IDLE) && start) ||
                ((state == COMPUTE) && (k_idx == LAST_INDEX));

            // Store eight output elements after
            // completing the current output row.
            result_we =
                (state == COMPUTE) && (k_idx == LAST_INDEX);

            // Status signals
            busy = (state == COMPUTE);
            done = (state == DONE);

        end

    end

endmodule
