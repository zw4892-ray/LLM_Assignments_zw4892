module Square(output G, P, input Ai, Bi);
    and (G, Ai, Bi);     // G = Ai · Bi
    xor (P, Ai, Bi);     // P = Ai ⊕ Bi
endmodule

module BigCircle(output G, P, input Gi, Pi, GiPrev, PiPrev);
    wire e;

    and (e, Pi, GiPrev); // e = Pi · GiPrev
    or  (G, e, Gi);      // G = Gi + (Pi · GiPrev)
    and (P, Pi, PiPrev); // P = Pi · PiPrev
endmodule

module SmallCircle(output Ci, input Gi);
    buf (Ci, Gi);        // Ci = Gi
endmodule

module Triangle(output Si, input Pi, CiPrev);
    xor (Si, Pi, CiPrev); // Si = Pi ⊕ CiPrev
endmodule

module KSA8(output [7:0] sum, output cout, input [7:0] a, b);

    // Initial Generate & Propagate
    wire [7:0] g, p;

    // Stage 1
    wire [7:0] g1, p1;

    // Stage 2
    wire [7:0] g2, p2;

    // Stage 3
    wire [7:0] g3, p3;

    // Carry signals
    wire [7:0] c;

    // 🔹 Stage 1: Pre-processing
    Square sq0(g[0], p[0], a[0], b[0]);
    Square sq1(g[1], p[1], a[1], b[1]);
    Square sq2(g[2], p[2], a[2], b[2]);
    Square sq3(g[3], p[3], a[3], b[3]);
    Square sq4(g[4], p[4], a[4], b[4]);
    Square sq5(g[5], p[5], a[5], b[5]);
    Square sq6(g[6], p[6], a[6], b[6]);
    Square sq7(g[7], p[7], a[7], b[7]);

    // 🔹 Stage 2: Prefix Tree

    // ---- Stage 1 (distance = 1) ----
    buf (g1[0], g[0]); buf (p1[0], p[0]);

    BigCircle bc1_1(g1[1], p1[1], g[1], p[1], g[0], p[0]);
    BigCircle bc1_2(g1[2], p1[2], g[2], p[2], g[1], p[1]);
    BigCircle bc1_3(g1[3], p1[3], g[3], p[3], g[2], p[2]);
    BigCircle bc1_4(g1[4], p1[4], g[4], p[4], g[3], p[3]);
    BigCircle bc1_5(g1[5], p1[5], g[5], p[5], g[4], p[4]);
    BigCircle bc1_6(g1[6], p1[6], g[6], p[6], g[5], p[5]);
    BigCircle bc1_7(g1[7], p1[7], g[7], p[7], g[6], p[6]);

    // ---- Stage 2 (distance = 2) ----
    buf (g2[0], g1[0]); buf (p2[0], p1[0]);
    buf (g2[1], g1[1]); buf (p2[1], p1[1]);

    BigCircle bc2_2(g2[2], p2[2], g1[2], p1[2], g1[0], p1[0]);
    BigCircle bc2_3(g2[3], p2[3], g1[3], p1[3], g1[1], p1[1]);
    BigCircle bc2_4(g2[4], p2[4], g1[4], p1[4], g1[2], p1[2]);
    BigCircle bc2_5(g2[5], p2[5], g1[5], p1[5], g1[3], p1[3]);
    BigCircle bc2_6(g2[6], p2[6], g1[6], p1[6], g1[4], p1[4]);
    BigCircle bc2_7(g2[7], p2[7], g1[7], p1[7], g1[5], p1[5]);

    // ---- Stage 3 (distance = 4) ----
    buf (g3[0], g2[0]); buf (p3[0], p2[0]);
    buf (g3[1], g2[1]); buf (p3[1], p2[1]);
    buf (g3[2], g2[2]); buf (p3[2], p2[2]);
    buf (g3[3], g2[3]); buf (p3[3], p2[3]);

    BigCircle bc3_4(g3[4], p3[4], g2[4], p2[4], g2[0], p2[0]);
    BigCircle bc3_5(g3[5], p3[5], g2[5], p2[5], g2[1], p2[1]);
    BigCircle bc3_6(g3[6], p3[6], g2[6], p2[6], g2[2], p2[2]);
    BigCircle bc3_7(g3[7], p3[7], g2[7], p2[7], g2[3], p2[3]);

    // 🔹 Carry Extraction (Gray Cells)
    SmallCircle sc0(c[0], g[0]);
    SmallCircle sc1(c[1], g1[1]);
    SmallCircle sc2(c[2], g2[2]);
    SmallCircle sc3(c[3], g2[3]);
    SmallCircle sc4(c[4], g3[4]);
    SmallCircle sc5(c[5], g3[5]);
    SmallCircle sc6(c[6], g3[6]);
    SmallCircle sc7(c[7], g3[7]);

    // 🔹 Stage 3: Sum Computation
    Triangle tr0(sum[0], p[0], 1'b0);
    Triangle tr1(sum[1], p[1], c[0]);
    Triangle tr2(sum[2], p[2], c[1]);
    Triangle tr3(sum[3], p[3], c[2]);
    Triangle tr4(sum[4], p[4], c[3]);
    Triangle tr5(sum[5], p[5], c[4]);
    Triangle tr6(sum[6], p[6], c[5]);
    Triangle tr7(sum[7], p[7], c[6]);

    // Final carry-out
    buf (cout, c[7]);

endmodule