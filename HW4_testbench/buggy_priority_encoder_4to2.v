
module priority_encoder_4to2 (
    input [3:0] in,
    output reg [1:0] out,
    output reg valid
);
    always @(*) begin
        valid = 1'b1;
        if (in[0])      out = 2'b00; // BUG: 把 bit 0 改成了最高优先级
        else if (in[1]) out = 2'b01;
        else if (in[2]) out = 2'b10;
        else if (in[3]) out = 2'b11; // BUG: 把 bit 3 改成了最低优先级
        else begin
            out = 2'b00;
            valid = 1'b0;
        end
    end
endmodule
