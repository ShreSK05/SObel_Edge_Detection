// edge_controller.v
// FSM that controls the edge detection pipeline:
// 1. Reads 16384 pixels from input_frame_buffer sequentially
// 2. Feeds pixels through line_buffer (3-row window)
// 3. Sobel result written to output_frame_buffer
// 4. Sets processing_done HIGH when all pixels processed
// Runs once at power-on/reset before VGA display begins
`timescale 1ns / 1ps
// edge_controller.v - FSM controlling edge detection pipeline
// (rest of your existing code is correct - just add timescale)
module edge_controller (
    input  wire        clk,
    input  wire        reset,

    // Input frame buffer interface
    output reg  [13:0] in_addr,       // Address to read from input buffer
    input  wire [7:0]  in_pixel,      // Pixel data returned (1 cycle latency)

    // Line buffer interface
    output wire [7:0]  lb_pixel_in,   // Pixel fed into line buffer
    output reg         lb_enable,     // Advance line buffer

    // Sobel output interface
    input  wire [7:0]  edge_pixel,    // Edge result from sobel
    input  wire        edge_valid,    // Edge result is valid

    // Output frame buffer write interface
    output reg  [13:0] out_wr_addr,
    output reg  [7:0]  out_wr_data,
    output reg         out_wr_en,

    // Done flag
    output reg         processing_done
);

    localparam TOTAL_PIXELS = 14'd16383;  // 128*128 - 1 = 16383 (max index)

    // FSM states
    localparam S_IDLE    = 3'd0;
    localparam S_FEED    = 3'd1;   // Feed pixels into pipeline
    localparam S_DRAIN   = 3'd2;   // Drain remaining pipeline pixels
    localparam S_DONE    = 3'd3;   // Processing complete

    reg [2:0]  state      = S_IDLE;
    reg [13:0] read_ptr   = 14'd0;  // Input read pointer
    reg [13:0] write_ptr  = 14'd0;  // Output write pointer
    reg [3:0]  drain_cnt  = 4'd0;   // Count drain cycles

    // Pipeline latency: line_buffer (1 cycle) + sobel (1 cycle) = 2 cycles
    // Add extra margin: drain for 4 cycles after last pixel
    localparam DRAIN_CYCLES = 4'd4;

    // Connect pixel to line buffer input
    assign lb_pixel_in = in_pixel;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state           <= S_IDLE;
            read_ptr        <= 14'd0;
            write_ptr       <= 14'd0;
            drain_cnt       <= 4'd0;
            in_addr         <= 14'd0;
            lb_enable       <= 1'b0;
            out_wr_en       <= 1'b0;
            out_wr_addr     <= 14'd0;
            out_wr_data     <= 8'h00;
            processing_done <= 1'b0;
        end else begin
            // Default: disable write
            out_wr_en <= 1'b0;

            case (state)

                // ----------------------------------------
                S_IDLE: begin
                    read_ptr  <= 14'd0;
                    write_ptr <= 14'd0;
                    in_addr   <= 14'd0;
                    lb_enable <= 1'b0;
                    state     <= S_FEED;
                end

                // ----------------------------------------
                S_FEED: begin
                    lb_enable <= 1'b1;

                    // Advance read pointer each cycle
                    if (read_ptr < TOTAL_PIXELS) begin
                        read_ptr <= read_ptr + 1;
                        in_addr  <= in_addr  + 1;
                    end else begin
                        // All pixels fed - now drain pipeline
                        lb_enable <= 1'b0;
                        drain_cnt <= 4'd0;
                        state     <= S_DRAIN;
                    end

                    // Write edge result when valid
                    if (edge_valid) begin
                        out_wr_addr <= write_ptr;
                        out_wr_data <= edge_pixel;
                        out_wr_en   <= 1'b1;
                        if (write_ptr < TOTAL_PIXELS)
                            write_ptr <= write_ptr + 1;
                    end
                end

                // ----------------------------------------
                S_DRAIN: begin
                    lb_enable <= 1'b0;

                    // Keep writing any remaining valid outputs
                    if (edge_valid) begin
                        out_wr_addr <= write_ptr;
                        out_wr_data <= edge_pixel;
                        out_wr_en   <= 1'b1;
                        if (write_ptr < TOTAL_PIXELS)
                            write_ptr <= write_ptr + 1;
                    end

                    // Wait for pipeline to fully drain
                    if (drain_cnt == DRAIN_CYCLES - 1) begin
                        state <= S_DONE;
                    end else begin
                        drain_cnt <= drain_cnt + 1;
                    end
                end

                // ----------------------------------------
                S_DONE: begin
                    processing_done <= 1'b1;
                    out_wr_en       <= 1'b0;
                    lb_enable       <= 1'b0;
                end

                default: state <= S_IDLE;

            endcase
        end
    end

endmodule