`timescale 1ns / 1ps
// line_buffer.v - 3-row sliding window for 128px wide image

module line_buffer (
    input  wire        clk,
    input  wire        reset,
    input  wire        enable,
    input  wire [7:0]  pixel_in,
    output wire [7:0]  p00, p01, p02,
    output wire [7:0]  p10, p11, p12,
    output wire [7:0]  p20, p21, p22
);
    reg [7:0] line0 [0:127];
    reg [7:0] line1 [0:127];
    reg [7:0] row0  [0:2];
    reg [7:0] row1  [0:2];
    reg [7:0] row2  [0:2];
    reg [6:0] wr_ptr = 7'd0;

    integer k;
    initial begin
        for (k = 0; k < 128; k = k + 1) begin
            line0[k] = 8'h00;
            line1[k] = 8'h00;
        end
        row0[0]=8'h00; row0[1]=8'h00; row0[2]=8'h00;
        row1[0]=8'h00; row1[1]=8'h00; row1[2]=8'h00;
        row2[0]=8'h00; row2[1]=8'h00; row2[2]=8'h00;
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            wr_ptr <= 7'd0;
        end else if (enable) begin
            line1[wr_ptr] <= line0[wr_ptr];
            line0[wr_ptr] <= pixel_in;
            row0[2]<=row0[1]; row0[1]<=row0[0]; row0[0]<=line1[wr_ptr];
            row1[2]<=row1[1]; row1[1]<=row1[0]; row1[0]<=line0[wr_ptr];
            row2[2]<=row2[1]; row2[1]<=row2[0]; row2[0]<=pixel_in;
            if (wr_ptr == 7'd127) wr_ptr <= 7'd0;
            else wr_ptr <= wr_ptr + 1;
        end
    end

    assign p00=row0[2]; assign p01=row0[1]; assign p02=row0[0];
    assign p10=row1[2]; assign p11=row1[1]; assign p12=row1[0];
    assign p20=row2[2]; assign p21=row2[1]; assign p22=row2[0];

endmodule