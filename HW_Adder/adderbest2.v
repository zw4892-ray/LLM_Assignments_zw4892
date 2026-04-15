module KSA8 (
    input [7:0] a,
    input [7:0] b,
    output [7:0] sum,
    output cout
);
    wire [7:0] p, g; // propagate and generate
    wire [8:0] c;
    // carry

    // generate propagate and generate signals
    assign p = a ^ b;
    assign g = a & b;

    // black cells and gray cells connections for a kogge-stone adder
    wire [7:0] g1, p1;
    wire [7:0] g2, p2;
    wire [7:0] g3, p3;

    // stage 1
    assign g1[0] = g[0];
    assign p1[0] = p[0];
    assign g1[7:1] = g[7:1] | (p[7:1] & g[6:0]);
    assign p1[7:1] = p[7:1] & p[6:0];

    // stage 2
    assign g2[1:0] = g1[1:0];
    assign p2[1:0] = p1[1:0];
    assign g2[7:2] = g1[7:2] | (p1[7:2] & g1[5:0]);
    assign p2[7:2] = p1[7:2] & p1[5:0];

    // stage 3
    assign g3[3:0] = g2[3:0];
    assign p3[3:0] = p2[3:0];
    assign g3[7:4] = g2[7:4] | (p2[7:4] & g2[3:0]);
    assign p3[7:4] = p2[7:4] & p2[3:0];

    // carry resolution:
    assign c[0] = 1'b0;      // cin  0
    assign c[1] = g[0];      // 
    assign c[2] = g1[1];     // 
    assign c[3] = g2[2];     // 
    assign c[4] = g2[3];     // 
    assign c[5] = g3[4];     // 
    assign c[6] = g3[5];     // 
    assign c[7] = g3[6];     // 

    assign cout = g3[7];     // 
    assign sum = p ^ c[7:0]; // sum

endmodule