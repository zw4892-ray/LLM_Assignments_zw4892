import subprocess, re, os, json 

def synthesize(verilog_file, top_module, lib_file='nangate45.lib'): 
    env = os.environ.copy() 
    env['ADDER_FILE']  = verilog_file 
    env['TOP_MODULE']  = top_module 
    result = subprocess.run( 
        ['yosys', '-s', 'synth_adder.ys'], 
        capture_output=True, text=True, env=env) 
    print(result.stdout)
    return parse_stats(result.stdout + result.stderr) 

def parse_stats(log):
    ppa = {'area_um2': 0, 'cell_count': 0, 'logic_levels': 0}
    
    # 1. 匹配面积 (stat 命令输出)
    area_matches = re.findall(r"Chip area.*:\s+([\d.]+)", log)
    if area_matches:
        ppa['area_um2'] = float(area_matches[-1])
        
    # 2. 匹配单元数量 (stat 命令输出)
    total_cells_match = re.search(r"^\s*(\d+)\s+[\d.]+\s+cells", log, re.MULTILINE)
    if total_cells_match:
        ppa['cell_count'] = int(total_cells_match.group(1))
    else:
        # 备选方案：如果找不到 cells 行，就累加 INV_X1, NAND2_X1 等明细行
        # 匹配格式： 行首空格 + 数字 + 空格 + 面积 + 空格 + 单元名
        # 例子: "   8    4.256   INV_X1"
        detail_matches = re.findall(r"^\s*(\d+)\s+[\d.]+\s+([A-Z0-9_$]+)", log, re.MULTILINE)
        total = 0
        for count, name in detail_matches:
            if name not in ["cells", "wires", "bits", "ports"]:
                total += int(count)
        ppa['cell_count'] = total  
    # 3. 匹配逻辑层级 (针对你刚才看到的 ltp 输出格式)
    # 它可以匹配 "length=16" 或者 "Design has 16 levels"
    level_match = re.search(r"length=(\d+)", log)
    if not level_match:
        level_match = re.search(r"Design has (\d+) levels", log)
        
    if level_match:
        ppa['logic_levels'] = int(level_match.group(1))
    
    return ppa

if __name__ == "__main__":
    # 示例调用
    stats = synthesize('RCA8_LLM.v', 'RCA8')
    print("\n--- Synthesis Results ---")
    print(json.dumps(stats, indent=4))