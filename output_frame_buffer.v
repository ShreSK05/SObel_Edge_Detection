`timescale 1ns / 1ps
// output_frame_buffer.v - Dual-port BRAM for edge results

module output_frame_buffer (
    input  wire        wr_clk,
    input  wire        wr_en,
    input  wire [13:0] wr_addr,
    input  wire [7:0]  wr_data,
    input  wire        rd_clk,
    input  wire [13:0] rd_addr,
    output reg  [7:0]  rd_data
);
    (* ram_style = "block" *)
    reg [7:0] mem [0:16383];

    integer i;
    initial begin
        for (i = 0; i < 16384; i = i + 1)
            mem[i] = 8'h00;
    end

    always @(posedge wr_clk) begin
        if (wr_en)
            mem[wr_addr] <= wr_data;
    end

    always @(posedge rd_clk) begin
        rd_data <= mem[rd_addr];
    end

endmodule