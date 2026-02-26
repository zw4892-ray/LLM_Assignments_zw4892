
module mux8to1_tb;
    reg [7:0] in;
    reg [2:0] sel;
    wire out;
    mux8to1 uut (.in(in), .sel(sel), .out(out));
    initial begin
        in = 8'b11001010;
        sel = 3'b000; #10; if (out !== 0) $display("Fail 000");
        sel = 3'b111; #10; if (out !== 1) $display("Fail 111");
        $display("passed!");
        $finish;
    end
endmodule
