
`timescale 1ns / 1ps
module binary_to_bcd_tb;
    reg [7:0] bin;
    wire [3:0] hundreds, tens, ones;

    binary_to_bcd uut (.bin(bin), .hundreds(hundreds), .tens(tens), .ones(ones));

    initial begin
        bin = 8'd123; #10;
        $display("Input: %d, BCD: %d %d %d", bin, hundreds, tens, ones);
        bin = 8'd255; #10;
        $display("Input: %d, BCD: %d %d %d", bin, hundreds, tens, ones);
        $finish;
    end
endmodule
