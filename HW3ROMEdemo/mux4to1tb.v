
module mux4to1_tb;
    reg [3:0] in;
    reg [1:0] sel;
    wire out;
    mux4to1 uut (.in(in), .sel(sel), .out(out));
    initial begin
        in = 4'b1010;
        sel = 2'b00; #10; if (out !== 0) $display("Fail 00");
        sel = 2'b01; #10; if (out !== 1) $display("Fail 01");
        sel = 2'b10; #10; if (out !== 0) $display("Fail 10");
        sel = 2'b11; #10; if (out !== 1) $display("Fail 11");
        $display("passed!");
        $finish;
    end
endmodule
