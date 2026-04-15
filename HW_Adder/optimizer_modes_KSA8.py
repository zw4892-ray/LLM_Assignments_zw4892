import json, os, re, subprocess, shutil
from openai import OpenAI

# ================= 配置区 =================
API_KEY = "your api key" 
MODEL_NAME = "gpt-4o" 

client = OpenAI(api_key=API_KEY, base_url=BASE_URL)

# 模式配置
MODES = {
    "A": {"target": 14, "desc": "Area Minimization", "instruction": "Focus on reducing area and cell count. A simple architecture like RCA is fine as long as logic levels <= 14."},
    "B": {"target": 6,  "desc": "Delay Minimization", "instruction": "Focus on reducing delay. You MUST use high-performance tree-based structures like Kogge-Stone or Han-Carlson to reach logic levels <= 6."},
    "C": {"target": 10, "desc": "Balanced Mode",      "instruction": "Optimize for Area-Delay Product. Target logic levels <= 10 while keeping the cell count reasonable (use CLA or hybrid)."}
}

# ==========================================

def get_system_prompt(mode_config):
    return f"""You are a senior hardware architect. Module name MUST be 'KSA8'. 
Do not use the '+' operator; use gate-level or structural descriptions.
CURRENT GOAL: {mode_config['desc']}. 
TARGET: Logic Levels <= {mode_config['target']}.
INSTRUCTION: {mode_config['instruction']}
Respond ONLY with Verilog code."""

def parse_stats(log):
    ppa = {'area_um2': 0.0, 'cell_count': 0, 'logic_levels': 0}
    # 面积匹配
    area_match = re.search(r"Chip area.*:\s+([\d.]+)", log)
    if area_match: ppa['area_um2'] = float(area_match.group(1))
    
    # 单元数匹配 (针对 56 57.456 cells 格式)
    cell_match = re.search(r"^\s*(\d+)\s+[\d.]+\s+cells", log, re.MULTILINE)
    if cell_match:
        ppa['cell_count'] = int(cell_match.group(1))
    else:
        detail_matches = re.findall(r"^\s*(\d+)\s+[\d.]+\s+[A-Z0-9_$]+", log, re.MULTILINE)
        ppa['cell_count'] = sum(int(c) for c in detail_matches)
    
    # 层级匹配 (length=16)
    level_match = re.search(r"length=(\d+)", log)
    if level_match: ppa['logic_levels'] = int(level_match.group(1))
    
    return ppa

def synthesize(verilog_file, top_module):
    v_path = os.path.abspath(verilog_file)
    lib_path = os.path.abspath("nangate45.lib")
    ys_path = os.path.abspath("temp_synth.ys")
    
    # 动态生成脚本，确保绝对路径正确
    ys_content = f"""
read_verilog {v_path}
read_liberty -lib {lib_path}
hierarchy -check -top {top_module}
proc; opt; fsm; opt; memory; opt
techmap; opt
abc -liberty {lib_path}
flatten
read_liberty -lib {lib_path}
opt_clean -purge
ltp
stat -liberty {lib_path}
"""
    with open(ys_path, "w") as f: f.write(ys_content)

    result = subprocess.run(['yosys', '-s', ys_path], capture_output=True, text=True)
    full_log = result.stdout + result.stderr
    return parse_stats(full_log), full_log

def main():
    top = "KSA8"
    
    for mode_id, config in MODES.items():
        print(f"\n{'='*20} STARTING MODE {mode_id}: {config['desc']} {'='*20}")
        history = []
        best_in_mode = {'logic_levels': 999, 'area_um2': 999.0}
        
        # 初始 User Prompt
        history.append({'role':'user', 'content': f"Propose an 8-bit adder for {config['desc']}."})
        
        for i in range(1, 11): # 每个模式 10 次迭代
            print(f"  [Mode {mode_id} - Iter {i}] asking LLM...")
            verilog = client.chat.completions.create(
                model=MODEL_NAME, 
                messages=[{'role':'system','content':get_system_prompt(config)}] + history
            ).choices[0].message.content.strip()
            
            # 代码清洗
            verilog = re.sub(r"```verilog|```", "", verilog).strip()
            verilog = re.sub(r"module\s+\w+", f"module {top}", verilog, count=1)
            
            fname = f"mode_{mode_id}_iter_{i}.v"
            with open(fname, 'w') as f: f.write(verilog)
            
            ppa, log = synthesize(fname, top)
            
            if ppa['cell_count'] == 0:
                print(f"    >> FAILED: Syntax Error or No Cells.")
                history.append({'role':'user', 'content': "The code failed synthesis. Check syntax and try again."})
                continue
            
            print(f"    >> Area: {ppa['area_um2']} | Levels: {ppa['logic_levels']} (Target: <= {config['target']})")
            
            # 评估是否为当前模式的最佳设计
            is_better = False
            if mode_id == "A": # Mode A 优先看面积
                if ppa['logic_levels'] <= config['target'] and ppa['area_um2'] < best_in_mode['area_um2']:
                    is_better = True
            else: # Mode B/C 优先看层级
                if ppa['logic_levels'] < best_in_mode['logic_levels']:
                    is_better = True
            
            if is_better:
                best_in_mode = ppa
                shutil.copy(fname, f"best_design_Mode_{mode_id}.v")
                print(f"    🌟 New best for Mode {mode_id} saved!")

            # 反馈给 LLM
            feedback = f"Result: Area {ppa['area_um2']}, Levels {ppa['logic_levels']}. Target is <= {config['target']}."
            history.append({'role':'assistant', 'content': verilog})
            history.append({'role':'user', 'content': feedback})

if __name__ == "__main__":
    main()