module sequence_detector(
    input clk,
    input reset,
    input data_in,
    output reg detected
);

    // 状态编码
    parameter S_IDLE = 3'b000;
    parameter S_1    = 3'b001;
    parameter S_11   = 3'b010;
    parameter S_110  = 3'b011;
    parameter S_1101 = 3'b100;

    reg [2:0] current_state, next_state;

    always @(posedge clk) begin
        if (reset)
            current_state <= S_IDLE;
        else
            current_state <= next_state;
    end

    always @(*) begin
        case (current_state)
            S_IDLE: next_state = (data_in) ? S_1    : S_IDLE;
            S_1:    next_state = (data_in) ? S_11   : S_IDLE;
            S_11:   next_state = (data_in) ? S_11   : S_110;
            S_110:  next_state = (data_in) ? S_1101 : S_IDLE;
            S_1101: next_state = (data_in) ? S_11   : S_IDLE; // 支持重叠检测
            default: next_state = S_IDLE;
        endcase
    end

    always @(*) begin
        detected = (current_state == S_1101);
    end

endmodule