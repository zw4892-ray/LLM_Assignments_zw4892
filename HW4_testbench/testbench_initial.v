module tb_priority_encoder_4to2;
    reg [3:0] in;
    wire [1:0] out;
    wire valid;

    // Instantiate the module under test
    priority_encoder_4to2 uut (
        .in(in),
        .out(out),
        .valid(valid)
    );

    initial begin
        // Test case 1: All inputs are 0
        in = 4'b0000;
        #10;
        $display("Test 1: in=0000");

        // Test case 2: Only in[0] is 1
        in = 4'b0001;
        #10;
        $display("Test 2: in=0001");

        // Test case 3: Only in[1] is 1
        in = 4'b0010;
        #10;
        $display("Test 3: in=0010");

        // Test case 4: Only in[2] is 1
        in = 4'b0100;
        #10;
        $display("Test 4: in=0100");

        // Test case 5: Only in[3] is 1
        in = 4'b1000;
        #10;
        $display("Test 5: in=1000");

        // Test case 6: in[0] and in[1] are 1
        in = 4'b0011;
        #10;
        $display("Test 6: in=0011");

        // Test case 7: in[1] and in[2] are 1
        in = 4'b0110;
        #10;
        $display("Test 7: in=0110");

        // Test case 8: in[2] and in[3] are 1
        in = 4'b1100;
        #10;
        $display("Test 8: in=1100");

        // Test case 9: All inputs are 1
        in = 4'b1111;
        #10;
        $display("Test 9: in=1111");

        // Test case 10: Random case 1
        in = 4'b1010;
        #10;
        $display("Test 10: in=1010");

        // Test case 11: Random case 2
        in = 4'b0101;
        #10;
        $display("Test 11: in=0101");

        $finish;
    end
endmodule