module RCA8(a, b, cin, sum, cout);
    input [7:0] a, b;
    input cin;
    output [7:0] sum;
    output cout;

    // ---  (Level 0) ---
    //  G (Generate)  P (Propagate)
    wire [7:0] g0, p0;
    assign g0 = a & b;
    assign p0 = a ^ b;

    
    wire [7:0] G0, P0;
    assign G0[0] = g0[0] | (p0[0] & cin);
    assign P0[0] = p0[0];
    assign G0[7:1] = g0[7:1];
    assign P0[7:1] = p0[7:1];

    // --- Level 1: stage 1 (i combine i-1 ) ---
    wire [7:0] G1, P1;
    assign G1[0] = G0[0]; 
    assign P1[0] = P0[0];
    generate
        genvar i;
        for (i = 1; i < 8; i = i + 1) begin : stage1
            assign G1[i] = G0[i] | (P0[i] & G0[i-1]);
            assign P1[i] = P0[i] & P0[i-1];
        end
    endgenerate

    // --- Level 2: stage 2 (i combine i-2 ) ---
    wire [7:0] G2, P2;
    assign G2[1:0] = G1[1:0]; 
    assign P2[1:0] = P1[1:0];
    generate
        for (i = 2; i < 8; i = i + 1) begin : stage2
            assign G2[i] = G1[i] | (P1[i] & G1[i-2]);
            assign P2[i] = P1[i] & P1[i-2];
        end
    endgenerate

    // --- Level 3: stage 4 (i combine i-4 ) ---
    wire [7:0] G3, P3;
    assign G3[3:0] = G2[3:0]; 
    assign P3[3:0] = P2[3:0];
    generate
        for (i = 4; i < 8; i = i + 1) begin : stage3
            assign G3[i] = G2[i] | (P2[i] & G2[i-4]);
            assign P3[i] = P2[i] & P2[i-4];
        end
    endgenerate

    // --- final logic ---
    
    wire [7:0] carries;
    assign carries[0] = cin;        //  cin 
    assign carries[7:1] = G3[6:0];  // 

    assign sum = p0 ^ carries;      // sum 
    assign cout = G3[7];            // final 

endmodule