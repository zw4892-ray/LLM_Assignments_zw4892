`timescale 1ns/1ps

module RCA8_tb;

    // Testbench signals
    reg  [7:0] a, b;
    wire [7:0] sum;
    wire cout;

    // Expected values
    reg  [7:0] expected_sum;
    reg        expected_cout;
    reg  [8:0] temp_result; // 9-bit for carry

    // Instantiate DUT
    RCA8 uut (
        .sum(sum),
        .cout(cout),
        .a(a),
        .b(b)
    );

    // Internal carry signals
    wire [7:1] c;
    assign c = uut.c;

    // Task for checking results
    task check_result;
    begin
        temp_result   = a + b;
        expected_sum  = temp_result[7:0];
        expected_cout = temp_result[8];

        if ((sum === expected_sum) && (cout === expected_cout)) begin
            $display("PASS | a=%b b=%b | sum=%b cout=%b | c=%b",
                      a, b, sum, cout, c);
        end else begin
            $display("FAIL | a=%b b=%b | sum=%b cout=%b | EXPECTED sum=%b cout=%b | c=%b",
                      a, b, sum, cout, expected_sum, expected_cout, c);
        end
    end
    endtask

    initial begin
        // Dump waveform
        $dumpfile("RCA8_tb.vcd");
        $dumpvars(0, RCA8_tb);

        $display("=========== RCA8 TEST START ===========");

        // ============================
        // Test Case 1: All zeros
        // ============================
        a = 8'b00000000; b = 8'b00000000; #10;
        check_result();

        // ============================
        // Test Case 2: All ones
        // ============================
        a = 8'b11111111; b = 8'b11111111; #10;
        check_result();

        // ============================
        // Test Case 3: Full ripple carry
        // ============================
        a = 8'b00000001; b = 8'b11111111; #10;
        check_result();

        // ============================
        // Additional tests
        // ============================
        a = 8'b10101010; b = 8'b01010101; #10;
        check_result();

        a = 8'b00001111; b = 8'b00000001; #10;
        check_result();

        // Random tests
        repeat (5) begin
            a = $random;
            b = $random;
            #10;
            check_result();
        end

        $display("=========== TEST COMPLETE ===========");
        $finish;
    end

endmodule