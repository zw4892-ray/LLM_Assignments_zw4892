# constraints.sdc
# 设置目标时钟周期（单位通常为 ns）
create_clock -name clk -period 2.0

# 设置输入和输出延迟
set_input_delay 0.2 -clock clk [all_inputs]
set_output_delay 0.2 -clock clk [all_outputs]