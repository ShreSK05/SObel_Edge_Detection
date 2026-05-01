`timescale 1ns / 1ps
// sobel_edge.v - Sobel 3x3 Edge Detection

module sobel_edge #(
    parameter THRESHOLD = 8'd30
)(
    input  wire        clk,
    input  wire        reset,
    input  wire [7:0]  p00, p01, p02,
    input  wire [7:0]  p10, p11, p12,
    input  wire [7:0]  p20, p21, p22,
    input  wire        valid_in,
    output reg  [7:0]  edge_pixel,
    output reg         valid_out
);
    wire signed [10:0] s00 = {3'b000, p00};
    wire signed [10:0] s01 = {3'b000, p01};
    wire signed [10:0] s02 = {3'b000, p02};
    wire signed [10:0] s10 = {3'b000, p10};
    wire signed [10:0] s12 = {3'b000, p12};
    wire signed [10:0] s20 = {3'b000, p20};
    wire signed [10:0] s21 = {3'b000, p21};
    wire signed [10:0] s22 = {3'b000, p22};

    wire signed [10:0] Gx = (s02-s00) + ((s12-s10)<<<1) + (s22-s20);
    wire signed [10:0] Gy = (s00-s20) + ((s01-s21)<<<1) + (s02-s22);

    wire [10:0] abs_Gx = Gx[10] ? (~Gx + 1'b1) : Gx;
    wire [10:0] abs_Gy = Gy[10] ? (~Gy + 1'b1) : Gy;
    wire [11:0] magnitude = {1'b0, abs_Gx} + {1'b0, abs_Gy};

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            edge_pixel <= 8'h00;
            valid_out  <= 1'b0;
        end else begin
            valid_out <= valid_in;
            if (valid_in)
                edge_pixel <= (magnitude > {4'b0000, THRESHOLD}) ?
                               8'hFF : 8'h00;
            else
                edge_pixel <= 8'h00;
        end
    end

endmodule