module mux2to1(input a, input b, input sel, output out);
  assign out = sel ? b : a;
endmodule

module mux4to1(input [3:0] in, input [1:0] sel, output out);
  wire w0, w1;
  mux2to1 m0(.a(in[0]), .b(in[1]), .sel(sel[0]), .out(w0));
  mux2to1 m1(.a(in[2]), .b(in[3]), .sel(sel[0]), .out(w1));
  mux2to1 m2(.a(w0), .b(w1), .sel(sel[1]), .out(out));
endmodule

module mux8to1(input [7:0] in, input [2:0] sel, output out);
  wire w0, w1;
  mux4to1 m0(.in(in[3:0]), .sel(sel[1:0]), .out(w0));
  mux4to1 m1(.in(in[7:4]), .sel(sel[1:0]), .out(w1));
  mux2to1 m2(.a(w0), .b(w1), .sel(sel[2]), .out(out));
endmodule

