module mux2to1(input a, input b, input sel, output out);
  assign out = sel ? b : a;
endmodule

module mux4to1(input [3:0] in, input [1:0] sel, output out);
  wire y0, y1;

  mux2to1 m0(.a(in[0]), .b(in[1]), .sel(sel[0]), .out(y0));
  mux2to1 m1(.a(in[2]), .b(in[3]), .sel(sel[0]), .out(y1));
  mux2to1 m2(.a(y0),    .b(y1),    .sel(sel[1]), .out(out));
endmodule

