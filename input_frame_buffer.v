`timescale 1ns / 1ps
// input_frame_buffer.v - 128x128 grayscale image from input.mem

module input_frame_buffer (
    input  wire        clk,
    input  wire [13:0] addr,
    output reg  [7:0]  data_out
);
    (* ram_style = "block" *)
    reg [7:0] mem [0:16383];

    initial begin
        $readmemh("input.mem", mem);
        // Simulation debug - confirms file loaded
        $display("input_frame_buffer: mem[0]=%h mem[100]=%h mem[1000]=%h",
                  mem[0], mem[100], mem[1000]);
        if (mem[0] === 8'hxx)
            $display("ERROR: input.mem NOT LOADED - check file path!");
        else
            $display("OK: input.mem loaded successfully");
    end

    always @(posedge clk) begin
        data_out <= mem[addr];
    end

endmodule