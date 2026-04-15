`timescale 1ns / 1ps

module tb_adder8;

    // --- 1. 信号定义 ---
    reg [7:0] a;
    reg [7:0] b;
    reg cin;
    wire [7:0] sum;
    wire cout;

    // 内部参考信号与统计变量
    reg [8:0] expected;
    integer i, j, k;
    integer error_count = 0;
    integer pass_count = 0;

    // --- 2. 实例化待测设计 (DUT) ---
    // 注意：这里模块名改为你 Verilog 文件中的名字，如 RCA8 或 KSA8
    RCA8 dut (
        .a(a),
        .b(b),
        .cin(cin),
        .sum(sum),
        .cout(cout)
    );

    // --- 3. 测试逻辑 ---
    initial begin
        $display("=======================================");
        $display("start 8bits_adder test...");
        $display("=======================================");

        error_count = 0;
        pass_count = 0;

        // 遍历所有可能的 Cin (0 和 1)
        for (k = 0; k < 2; k = k + 1) begin
            cin = k;
            
            // 遍历所有 A (0-255)
            for (i = 0; i < 256; i = i + 1) begin
                a = i;
                
                // 遍历所有 B (0-255)
                for (j = 0; j < 256; j = j + 1) begin
                    b = j;
                    
                    // 计算参考值 (9位，第9位是 Cout)
                    expected = a + b + cin;
                    
                    #1; // 等待逻辑稳定

                    // --- 4. 自动比对逻辑 ---
                    if ({cout, sum} !== expected) begin
                        $display("[FAIL] A=%d, B=%d, Cin=%b | out: {Cout=%b, Sum=%d} | expect: {Cout=%b, Sum=%d}", 
                                  a, b, cin, cout, sum, expected[8], expected[7:0]);
                        error_count = error_count + 1;
                    end else begin
                        pass_count = pass_count + 1;
                    end
                end
            end
        end

        // --- 5. 打印最终报告 ---
        $display("\n=======================================");
        if (error_count == 0) begin
            $display("  test conclusion: [ PASS ]");
            $display("  passed %d test!", pass_count);
        end else begin
            $display("  test conclusion: [ FAIL ]");
            $display("  detect %d mistakes,please recheck the logic", error_count);
        end
        $display("=======================================");
        
        $finish; // 结束仿真
    end

    // (可选) 生成波形文件，方便调试
    initial begin
        $dumpfile("adder8_sim.vcd");
        $dumpvars(0, tb_adder8);
    end

endmodule