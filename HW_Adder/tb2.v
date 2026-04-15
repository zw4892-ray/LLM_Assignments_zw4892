`timescale 1ns / 1ps

module tb_adder8;

    // --- 1. 信号定义 ---
    reg [7:0] a;
    reg [7:0] b;
    reg cin; // 虽然设计没有端口，但 TB 保留此变量用于逻辑计算
    wire [7:0] sum;
    wire cout;

    // 内部参考信号与统计变量
    reg [8:0] expected;
    integer i, j;
    integer error_count = 0;
    integer pass_count = 0;

    // --- 2. 实例化待测设计 (DUT) ---
    // 注意：已移除 .cin(cin) 以匹配 adderbest2.v 的端口定义
    KSA8 dut (
        .a(a),
        .b(b),
        .sum(sum),
        .cout(cout)
    );

    // --- 3. 测试逻辑 ---
    initial begin
        $display("=======================================");
        $display("start tseting 8bits_adder (Cin initial = 0)...");
        $display("=======================================");

        error_count = 0;
        pass_count = 0;

        // 固定 cin 为 0 [根据要求]
        cin = 1'b0;

        // 遍历所有 A (0-255)
        for (i = 0; i < 256; i = i + 1) begin
            a = i;
            // 遍历所有 B (0-255)
            for (j = 0; j < 256; j = j + 1) begin
                b = j;
                
                // 计算参考值 (由于设计无 cin 端口，参考值不加 cin)
                expected = a + b; 
                
                #1; // 等待逻辑稳定

                // --- 4. 自动比对逻辑 ---
                if ({cout, sum} !== expected) begin
                    $display("[FAIL] A=%d, B=%d | out: {Cout=%b, Sum=%d} | expected: {Cout=%b, Sum=%d}", 
                              a, b, cout, sum, expected[8], expected[7:0]);
                    error_count = error_count + 1;
                end else begin
                    pass_count = pass_count + 1;
                end
            end
        end

        // --- 5. 打印最终报告 ---
        $display("\n=======================================");
        if (error_count == 0) begin
            $display("  conclusion: [ PASS ]");
            $display("  passed %d test!", pass_count);
        end else begin
            $display("  conclusion: [ FAIL ]");
            $display("  detected %d mistakes,please double check logic", error_count);
        end
        $display("=======================================");
        
        $finish;
    end

    // 生成波形文件
    initial begin
        $dumpfile("adder8_sim.vcd");
        $dumpvars(0, tb_adder8);
    end

endmodule