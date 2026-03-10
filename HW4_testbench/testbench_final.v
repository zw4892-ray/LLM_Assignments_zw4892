module tb_priority_encoder_4to2;
    reg [3:0] in;
    wire [1:0] out;
    wire valid;

    integer passed_tests, failed_tests;

    // Instantiate the module under test
    priority_encoder_4to2 uut (
        .in(in),
        .out(out),
        .valid(valid)
    );

    initial begin
        passed_tests = 0;
        failed_tests = 0;

        // Test case 1: All inputs are 0
        in = 4'b0000;
        #10;
        $display("Test 1: in=0000");
        if (out == 2'b00 && valid == 1'b0) begin
            $display("✓ Test 1 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 1 Failed: Expected out=00, valid=0, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 2: Only in[0] is 1
        in = 4'b0001;
        #10;
        $display("Test 2: in=0001");
        if (out == 2'b00 && valid == 1'b1) begin
            $display("✓ Test 2 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 2 Failed: Expected out=00, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 3: Only in[1] is 1
        in = 4'b0010;
        #10;
        $display("Test 3: in=0010");
        if (out == 2'b01 && valid == 1'b1) begin
            $display("✓ Test 3 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 3 Failed: Expected out=01, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 4: Only in[2] is 1
        in = 4'b0100;
        #10;
        $display("Test 4: in=0100");
        if (out == 2'b10 && valid == 1'b1) begin
            $display("✓ Test 4 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 4 Failed: Expected out=10, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 5: Only in[3] is 1
        in = 4'b1000;
        #10;
        $display("Test 5: in=1000");
        if (out == 2'b11 && valid == 1'b1) begin
            $display("✓ Test 5 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 5 Failed: Expected out=11, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 6: in[0] and in[1] are 1
        in = 4'b0011;
        #10;
        $display("Test 6: in=0011");
        if (out == 2'b01 && valid == 1'b1) begin
            $display("✓ Test 6 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 6 Failed: Expected out=01, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 7: in[1] and in[2] are 1
        in = 4'b0110;
        #10;
        $display("Test 7: in=0110");
        if (out == 2'b10 && valid == 1'b1) begin
            $display("✓ Test 7 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 7 Failed: Expected out=10, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 8: in[2] and in[3] are 1
        in = 4'b1100;
        #10;
        $display("Test 8: in=1100");
        if (out == 2'b11 && valid == 1'b1) begin
            $display("✓ Test 8 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 8 Failed: Expected out=11, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 9: All inputs are 1
        in = 4'b1111;
        #10;
        $display("Test 9: in=1111");
        if (out == 2'b11 && valid == 1'b1) begin
            $display("✓ Test 9 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 9 Failed: Expected out=11, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 10: Random case 1
        in = 4'b1010;
        #10;
        $display("Test 10: in=1010");
        if (out == 2'b11 && valid == 1'b1) begin
            $display("✓ Test 10 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 10 Failed: Expected out=11, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        // Test case 11: Random case 2
        in = 4'b0101;
        #10;
        $display("Test 11: in=0101");
        if (out == 2'b10 && valid == 1'b1) begin
            $display("✓ Test 11 Passed: out=%b, valid=%b", out, valid);
            passed_tests = passed_tests + 2;
        end else begin
            $display("✗ Test 11 Failed: Expected out=10, valid=1, Got out=%b, valid=%b", out, valid);
            failed_tests = failed_tests + 2;
        end

        $display("Test Summary:");
        $display("Total Tests Run: %0d", passed_tests + failed_tests);
        $display("Tests Passed: %0d", passed_tests);
        $display("Tests Failed: %0d", failed_tests);

        $finish;
    end
endmodule