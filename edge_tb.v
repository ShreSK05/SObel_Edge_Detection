`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09.03.2026 18:44:14
// Design Name: 
// Module Name: edge_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// edge_tb.v
// Complete testbench for 128x128 edge detection system
// Checks:
//   1. Reset behaviour
//   2. Processing completion (LED goes HIGH)
//   3. Output frame buffer contents saved to output.mem
//   4. VGA HSYNC / VSYNC timing
//   5. Pixel output during active video region

`timescale 1ns / 1ps

module edge_tb;

    // -------------------------------------------------------
    // DUT port signals
    // -------------------------------------------------------
    reg        CLK100MHZ  = 1'b0;
    reg        CPU_RESETN = 1'b0;   // Start in reset

    wire [3:0] VGA_R;
    wire [3:0] VGA_G;
    wire [3:0] VGA_B;
    wire       VGA_HS;
    wire       VGA_VS;
    wire       LED;

    // -------------------------------------------------------
    // DUT instantiation
    // -------------------------------------------------------
    edge_top dut (
        .CLK100MHZ  (CLK100MHZ),
        .CPU_RESETN (CPU_RESETN),
        .VGA_R      (VGA_R),
        .VGA_G      (VGA_G),
        .VGA_B      (VGA_B),
        .VGA_HS     (VGA_HS),
        .VGA_VS     (VGA_VS),
        .LED        (LED)
    );

    // -------------------------------------------------------
    // 100 MHz clock - 10 ns period
    // -------------------------------------------------------
    always #5 CLK100MHZ = ~CLK100MHZ;

    // -------------------------------------------------------
    // VGA timing verification variables
    // -------------------------------------------------------
    real    last_hs_time   = 0.0;
    real    last_vs_time   = 0.0;
    real    hs_period_ns   = 0.0;
    real    vs_period_ns   = 0.0;
    integer hs_count       = 0;
    integer vs_count       = 0;

    // Expected VGA timing for 640x480 @ 60Hz
    // HSYNC period = 800 pixels / 25MHz = 32000 ns
    // VSYNC period = 525 lines * 32000 ns = 16,800,000 ns
    localparam real HS_EXPECTED_NS = 32000.0;
    localparam real VS_EXPECTED_NS = 16800000.0;
    localparam real TOLERANCE      = 0.05;      // 5% tolerance

    // -------------------------------------------------------
    // HSYNC edge monitor
    // -------------------------------------------------------
    always @(negedge VGA_HS) begin
        hs_count = hs_count + 1;
        if (last_hs_time > 0.0) begin
            hs_period_ns = $realtime - last_hs_time;
            if (hs_count % 100 == 0) begin
                if ((hs_period_ns > HS_EXPECTED_NS*(1.0-TOLERANCE)) &&
                    (hs_period_ns < HS_EXPECTED_NS*(1.0+TOLERANCE)))
                    $display("[VGA OK]  HSYNC #%0d period = %0.1f ns (expected %0.0f ns)",
                             hs_count, hs_period_ns, HS_EXPECTED_NS);
                else
                    $display("[VGA ERR] HSYNC #%0d period = %0.1f ns - OUT OF RANGE!",
                             hs_count, hs_period_ns);
            end
        end
        last_hs_time = $realtime;
    end

    // -------------------------------------------------------
    // VSYNC edge monitor
    // -------------------------------------------------------
    always @(negedge VGA_VS) begin
        vs_count = vs_count + 1;
        if (last_vs_time > 0.0) begin
            vs_period_ns = $realtime - last_vs_time;
            $display("[VGA] VSYNC #%0d period = %0.3f ms (expected %0.3f ms)",
                     vs_count,
                     vs_period_ns/1000000.0,
                     VS_EXPECTED_NS/1000000.0);
        end
        last_vs_time = $realtime;
    end

    // -------------------------------------------------------
    // Main test sequence
    // -------------------------------------------------------
    integer timeout_cnt = 0;
    integer pass_cnt    = 0;
    integer fail_cnt    = 0;

    initial begin
        $display("=========================================");
        $display("  Edge Detection Testbench - 128x128    ");
        $display("  Nexys A7 / Vivado Simulation          ");
        $display("=========================================");

        // Step 1: Apply reset
        $display("[TEST] Applying reset...");
        CPU_RESETN = 1'b0;
        repeat(20) @(posedge CLK100MHZ);

        // Step 2: Release reset
        CPU_RESETN = 1'b1;
        $display("[TEST] Reset released. Processing started.");
        $display("[TEST] Waiting for LED (processing_done)...");

        // Step 3: Wait for LED (processing complete)
        // 128*128 = 16384 pixels + pipeline drain = ~16400 cycles max
        // Timeout at 100,000 cycles to be safe
        timeout_cnt = 0;
        while (LED == 1'b0 && timeout_cnt < 100000) begin
            @(posedge CLK100MHZ);
            timeout_cnt = timeout_cnt + 1;
        end

        // Step 4: Check completion
        if (LED == 1'b1) begin
            $display("[PASS] Processing DONE in %0d cycles (~%0.2f us)",
                     timeout_cnt, timeout_cnt * 0.01);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[FAIL] TIMEOUT: Processing not done after %0d cycles!",
                     timeout_cnt);
            fail_cnt = fail_cnt + 1;
        end

        // Step 5: Save output.mem
        $display("[TEST] Saving output frame buffer to output.mem...");
        $writememh("output.mem", dut.out_fb.mem, 0, 16383);
        $display("[TEST] output.mem saved - 16384 pixels (128x128)");

        // Step 6: Spot-check a few output pixels
        $display("[TEST] Spot-checking output buffer...");
        begin : pixel_check
            integer pix;
            integer edge_pixels_found;
            edge_pixels_found = 0;
            for (pix = 0; pix < 16384; pix = pix + 1) begin
                if (dut.out_fb.mem[pix] == 8'hFF)
                    edge_pixels_found = edge_pixels_found + 1;
            end
            $display("[INFO] Total edge pixels detected: %0d / 16384 (%0.1f%%)",
                     edge_pixels_found,
                     edge_pixels_found * 100.0 / 16384.0);
            if (edge_pixels_found > 0) begin
                $display("[PASS] Edge pixels found in output buffer");
                pass_cnt = pass_cnt + 1;
            end else begin
                $display("[WARN] No edge pixels found - check threshold or input.mem");
                fail_cnt = fail_cnt + 1;
            end
        end

        // Step 7: Let VGA run for 3 complete frames
        $display("[TEST] Running VGA for 3 frames to verify timing...");
        // 1 frame = 525 * 800 * 40ns = 16,800,000 ns = 16.8ms
        // 3 frames = 50,400,000 ns
        #50_400_000;

        // Step 8: Final VGA check
        if (hs_count > 0) begin
            $display("[PASS] HSYNC toggled %0d times", hs_count);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[FAIL] HSYNC never toggled!");
            fail_cnt = fail_cnt + 1;
        end

        if (vs_count >= 3) begin
            $display("[PASS] VSYNC toggled %0d times (3 full frames)", vs_count);
            pass_cnt = pass_cnt + 1;
        end else begin
            $display("[FAIL] VSYNC only toggled %0d times (expected >= 3)", vs_count);
            fail_cnt = fail_cnt + 1;
        end

        // Step 9: Summary
        $display("=========================================");
        $display("  TEST SUMMARY");
        $display("  PASSED: %0d", pass_cnt);
        $display("  FAILED: %0d", fail_cnt);
        if (fail_cnt == 0)
            $display("  RESULT: ALL TESTS PASSED");
        else
            $display("  RESULT: SOME TESTS FAILED - check above");
        $display("=========================================");

        $finish;
    end

    // -------------------------------------------------------
    // VCD waveform dump (open in Vivado or GTKWave)
    // -------------------------------------------------------
    initial begin
        $dumpfile("edge_sim.vcd");
        $dumpvars(0, edge_tb);
    end

    // -------------------------------------------------------
    // Watchdog - kill simulation if it hangs
    // -------------------------------------------------------
    initial begin
        #200_000_000;   // 200ms maximum
        $display("[WATCHDOG] Simulation exceeded 200ms - force stop");
        $finish;
    end

endmodule
