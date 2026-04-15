`timescale 1ns/1ps

module KSA8_tb;

    // Inputs
    reg [7:0] a, b;

    // Outputs
    wire [7:0] sum;
    wire cout;

    // Instantiate DUT
    KSA8 uut (
        .sum(sum),
        .cout(cout),
        .a(a),
        .b(b)
    );

    // Expected result
    reg [8:0] expected;

    integer i;

    // 🔹 Waveform dump (GTKWave)
    initial begin
        $dumpfile("ksa8.vcd");
        $dumpvars(0, KSA8_tb);
    end

    // 🔹 Internal Signal Monitoring
    initial begin
        $display("Time |   a    b   |   g        p        |   g1       p1       |   g2       p2       |   g3       p3       | sum cout");

        $monitor("%4t | %b %b | %b %b | %b %b | %b %b | %b %b | %b %b",
            $time,
            a, b,
            uut.g, uut.p,
            uut.g1, uut.p1,
            uut.g2, uut.p2,
            uut.g3, uut.p3,
            sum, cout
        );
    end

    // 🔹 Test Task with Validation
    task run_test;
        input [7:0] ta, tb;
        begin
            a = ta;
            b = tb;

            #10; // wait for propagation

            expected = ta + tb;

            if ({cout, sum} === expected)
                $display("PASS: a=%0d b=%0d => sum=%0d", ta, tb, sum);
            else
                $display("FAIL: a=%0d b=%0d => got=%0d expected=%0d",
                         ta, tb, {cout, sum}, expected);
        end
    endtask

    // 🔹 Stimulus
    initial begin

        // ---- Edge Cases ----
        run_test(8'd0,   8'd0);     // 0 + 0
        run_test(8'd255, 8'd1);     // overflow case
        run_test(8'd255, 8'd255);   // max + max
        run_test(8'd1,   8'd1);
        run_test(8'd128, 8'd128);

        // ---- Random Tests ----
        for (i = 0; i < 10; i = i + 1) begin
            run_test($random, $random);
        end

        // Finish simulation
        #20;
        $display("Simulation Finished.");
        $finish;
    end

endmodule