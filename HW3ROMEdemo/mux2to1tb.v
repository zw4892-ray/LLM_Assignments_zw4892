
module mux2to1_tb;
    reg a, b, sel;
    wire out;
    mux2to1 uut (.a(a), .b(b), .sel(sel), .out(out));
    initial begin
        a=0; b=1; sel=0; #10;
        a=0; b=1; sel=1; #10;
        $display("passed!"); // 必须有这个
        $finish;
    end
endmodule
