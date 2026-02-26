
module adder4_tb;
    reg [3:0] a, b;
    reg cin;
    wire [3:0] sum;
    wire cout;
    ripple_carry_adder_4bit uut (.a(a), .b(b), .cin(cin), .sum(sum), .cout(cout));
    initial begin
        // 测试用例 1: 5 + 3 = 8
        a = 4'd5; b = 4'd3; cin = 0; #10;
        if (sum == 4'd8 && cout == 0) begin
            // 测试用例 2: 15 + 1 = 16 (进位)
            a = 4'hf; b = 4'h1; cin = 0; #10;
            if (sum == 4'd0 && cout == 1) $display("passed!");
        end
        $finish;
    end
endmodule
