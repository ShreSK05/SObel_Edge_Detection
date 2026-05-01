`timescale 1ns / 1ps
// edge_top.v - fixed valid_pipe to 3 stages

module edge_top (
    input  wire        CLK100MHZ,
    input  wire        CPU_RESETN,
    output wire [3:0]  VGA_R,
    output wire [3:0]  VGA_G,
    output wire [3:0]  VGA_B,
    output wire        VGA_HS,
    output wire        VGA_VS,
    output wire        LED
);
    wire reset = ~CPU_RESETN;

    wire [13:0] in_addr;
    wire [7:0]  in_pixel;
    wire [7:0]  lb_pixel_in;
    wire        lb_enable;
    wire [7:0]  p00,p01,p02,p10,p11,p12,p20,p21,p22;
    wire [7:0]  edge_pixel;
    wire        edge_valid;
    wire [13:0] out_wr_addr;
    wire [7:0]  out_wr_data;
    wire        out_wr_en;
    wire [13:0] vga_rd_addr;
    wire [7:0]  vga_rd_pixel;
    wire        processing_done;

    // ── FIXED: 3-stage valid pipeline (was 2-stage) ─────────
    // line_buffer = 1 cycle latency
    // sobel       = 1 cycle latency
    // extra margin= 1 cycle
    // Total       = 3 cycles safe
    reg [2:0] valid_pipe = 3'b000;
    always @(posedge CLK100MHZ or posedge reset) begin
        if (reset)
            valid_pipe <= 3'b000;
        else
            valid_pipe <= {valid_pipe[1:0], lb_enable};
    end

    input_frame_buffer in_fb (
        .clk(CLK100MHZ), .addr(in_addr), .data_out(in_pixel)
    );

    line_buffer lb_inst (
        .clk(CLK100MHZ), .reset(reset), .enable(lb_enable),
        .pixel_in(lb_pixel_in),
        .p00(p00),.p01(p01),.p02(p02),
        .p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22)
    );

    sobel_edge #(.THRESHOLD(8'd30)) sobel_inst (
        .clk(CLK100MHZ), .reset(reset),
        .p00(p00),.p01(p01),.p02(p02),
        .p10(p10),.p11(p11),.p12(p12),
        .p20(p20),.p21(p21),.p22(p22),
        .valid_in(valid_pipe[2]),   // ← FIXED: was valid_pipe[1]
        .edge_pixel(edge_pixel),
        .valid_out(edge_valid)
    );

    output_frame_buffer out_fb (
        .wr_clk(CLK100MHZ), .wr_en(out_wr_en),
        .wr_addr(out_wr_addr), .wr_data(out_wr_data),
        .rd_clk(CLK100MHZ),
        .rd_addr(vga_rd_addr), .rd_data(vga_rd_pixel)
    );

    edge_controller ctrl_inst (
        .clk(CLK100MHZ), .reset(reset),
        .in_addr(in_addr), .in_pixel(in_pixel),
        .lb_pixel_in(lb_pixel_in), .lb_enable(lb_enable),
        .edge_pixel(edge_pixel), .edge_valid(edge_valid),
        .out_wr_addr(out_wr_addr), .out_wr_data(out_wr_data),
        .out_wr_en(out_wr_en),
        .processing_done(processing_done)
    );

    vga_display vga_inst (
        .clk_100mhz(CLK100MHZ), .reset(reset),
        .fb_addr(vga_rd_addr), .fb_pixel(vga_rd_pixel),
        .hsync(VGA_HS), .vsync(VGA_VS),
        .vga_r(VGA_R), .vga_g(VGA_G), .vga_b(VGA_B)
    );

    assign LED = processing_done;

endmodule