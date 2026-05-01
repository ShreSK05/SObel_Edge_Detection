`timescale 1ns / 1ps
// vga_display.v - FIXED
// Uses multiply+shift instead of division (synthesis safe)
// Registered address and video_on to match BRAM latency

module vga_display (
    input  wire        clk_100mhz,
    input  wire        reset,
    output wire [13:0] fb_addr,
    input  wire [7:0]  fb_pixel,
    output wire        hsync,
    output wire        vsync,
    output wire [3:0]  vga_r,
    output wire [3:0]  vga_g,
    output wire [3:0]  vga_b
);
    wire        video_on;
    wire        p_tick;
    wire [9:0]  pixel_x;
    wire [9:0]  pixel_y;

    vga_sync sync_inst (
        .clk_100mhz (clk_100mhz),
        .reset      (reset),
        .hsync      (hsync),
        .vsync      (vsync),
        .video_on   (video_on),
        .p_tick     (p_tick),
        .pixel_x    (pixel_x),
        .pixel_y    (pixel_y)
    );

    // ── FIXED SCALING - multiply + shift (NO division) ─────
    // img_x = pixel_x / 5  → (pixel_x * 205) >> 10
    //         640/128 = 5, multiply trick error < 0.1%
    // img_y = pixel_y / 3.75 → (pixel_y * 273) >> 10
    //         480/128 = 3.75, multiply trick error < 0.1%

    wire [16:0] scale_x = pixel_x * 9'd205;
    wire [16:0] scale_y = pixel_y * 9'd273;

    wire [6:0] img_x_raw = scale_x[16:10];
    wire [6:0] img_y_raw = scale_y[16:10];

    // Clamp to 127 maximum
    wire [6:0] img_x = (img_x_raw > 7'd127) ? 7'd127 : img_x_raw;
    wire [6:0] img_y = (img_y_raw > 7'd127) ? 7'd127 : img_y_raw;

    // Frame buffer address
    wire [13:0] addr_next = ({7'b0, img_y} << 7) | {7'b0, img_x};

    // ── FIXED: Register address 1 cycle ahead of BRAM read ─
    // BRAM has 1-cycle synchronous read latency
    // We register the address so fb_pixel arrives in sync
    // with the delayed video_on signal
    reg [13:0] fb_addr_reg = 14'd0;
    always @(posedge clk_100mhz) begin
        fb_addr_reg <= addr_next;
    end
    assign fb_addr = fb_addr_reg;

    // ── FIXED: Delay video_on by 1 cycle to match BRAM ─────
    reg video_on_d = 1'b0;
    always @(posedge clk_100mhz) begin
        video_on_d <= video_on;
    end

    // ── VGA color output ────────────────────────────────────
    wire [3:0] intensity = video_on_d ? fb_pixel[7:4] : 4'h0;

    assign vga_r = intensity;
    assign vga_g = intensity;
    assign vga_b = intensity;

endmodule