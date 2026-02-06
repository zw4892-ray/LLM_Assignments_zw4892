module tb;
    reg clk, reset, data_in;
    wire detected;
    integer mismatch_count = 0;

    sequence_detector dut (
        .clk(clk),
        .reset(reset),
        .data_in(data_in),
        .detected(detected)
    );

    // 
    always #5 clk = ~clk;

    initial begin
        clk = 0; reset = 1; data_in = 0; mismatch_count = 0;
        #15 reset = 0;

        // 测试序列: 1 -> 1 -> 0 -> 1 (预期 detected 在最后变为 1)
        @(posedge clk) data_in = 1;
        @(posedge clk) data_in = 1;
        @(posedge clk) data_in = 0;
        @(posedge clk) data_in = 1;
        
        #2; // 
        if (detected !== 1) mismatch_count = mismatch_count + 1;

        $display("mismatches: %d", mismatch_count);
        $finish;
    end
endmodule