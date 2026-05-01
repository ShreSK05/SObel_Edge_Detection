`timescale 1ns / 1ps
// vga_sync.v - 640x480 @ 60Hz VGA Sync Generator

module vga_sync (
    input  wire        clk_100mhz,
    input  wire        reset,
    output wire        hsync,
    output wire        vsync,
    output wire        video_on,
    output wire        p_tick,
    output wire [9:0]  pixel_x,
    output wire [9:0]  pixel_y
);
    reg [1:0] clk_div = 2'b00;
    reg       clk_25  = 1'b0;

    always @(posedge clk_100mhz or posedge reset) begin
        if (reset) begin
            clk_div <= 2'b00;
            clk_25  <= 1'b0;
        end else begin
            clk_div <= clk_div + 1;
            if      (clk_div == 2'b01) clk_25 <= 1'b1;
            else if (clk_div == 2'b11) clk_25 <= 1'b0;
        end
    end

    assign p_tick = clk_25;

    localparam H_DISPLAY = 640;
    localparam H_FRONT   =  16;
    localparam H_SYNC    =  96;
    localparam H_BACK    =  48;
    localparam H_TOTAL   = 800;
    localparam V_DISPLAY = 480;
    localparam V_FRONT   =  10;
    localparam V_SYNC    =   2;
    localparam V_BACK    =  33;
    localparam V_TOTAL   = 525;

    reg [9:0] h_count = 10'd0;
    reg [9:0] v_count = 10'd0;

    always @(posedge clk_25 or posedge reset) begin
        if (reset) h_count <= 10'd0;
        else if (h_count == H_TOTAL - 1) h_count <= 10'd0;
        else h_count <= h_count + 1;
    end

    always @(posedge clk_25 or posedge reset) begin
        if (reset) v_count <= 10'd0;
        else if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1) v_count <= 10'd0;
            else v_count <= v_count + 1;
        end
    end

    assign hsync    = ~((h_count >= H_DISPLAY + H_FRONT) &&
                        (h_count <  H_DISPLAY + H_FRONT + H_SYNC));
    assign vsync    = ~((v_count >= V_DISPLAY + V_FRONT) &&
                        (v_count <  V_DISPLAY + V_FRONT + V_SYNC));
    assign video_on = (h_count < H_DISPLAY) && (v_count < V_DISPLAY);
    assign pixel_x  = h_count;
    assign pixel_y  = v_count;

endmodule