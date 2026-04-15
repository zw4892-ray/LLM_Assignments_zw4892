import json, os, re, subprocess, shutil
from openai import OpenAI

# ================= 配置区 =================
API_KEY = "your api keys" 
MODEL_NAME = "gpt-4o" 

client = OpenAI(api_key=API_KEY, base_url=BASE_URL)

MODES = {
    "A": {"target": 14, "desc": "Area Minimization", "instruction": "Focus on reducing area and cell count. RCA-like structures are preferred."},
    "B": {"target": 6,  "desc": "Delay Minimization", "instruction": "Focus on reducing delay. Use high-performance tree-based structures (Kogge-Stone/Han-Carlson)."},
    "C": {"target": 10, "desc": "Balanced Mode",      "instruction": "Optimize for Area-Delay Product. Target levels <= 10 using CLA or hybrid structures."}
}
# ==========================================

def get_system_prompt(mode_config):
    return f"""You are a senior hardware architect. Module name MUST be 'RCA8'. 
Do not use '+' operator; use gate-level or structural descriptions.
CURRENT GOAL: {mode_config['desc']}. TARGET: Logic Levels <= {mode_config['target']}.
{mode_config['instruction']} Respond ONLY with Verilog code."""

def parse_stats(log):
    ppa = {'area_um2': 0.0, 'cell_count': 0, 'logic_levels': 0}
    area_match = re.search(r"Chip area.*:\s+([\d.]+)", log)
    if area_match: ppa['area_um2'] = float(area_match.group(1))
    
    cell_match = re.search(r"^\s*(\d+)\s+[\d.]+\s+cells", log, re.MULTILINE)
    if cell_match:
        ppa['cell_count'] = int(cell_match.group(1))
    else:
        detail_matches = re.findall(r"^\s*(\d+)\s+[\d.]+\s+[A-Z0-9_$]+", log, re.MULTILINE)
        ppa['cell_count'] = sum(int(c) for c in detail_matches)
    
    level_match = re.search(r"length=(\d+)", log)
    if level_match: ppa['logic_levels'] = int(level_match.group(1))
    return ppa

def synthesize(verilog_file, top_module):
    v_path = os.path.abspath(verilog_file)
    lib_path = os.path.abspath("nangate45.lib")
    ys_path = os.path.abspath("temp_synth.ys")
    
    ys_content = f"read_verilog {v_path}\nread_liberty -lib {lib_path}\nhierarchy -check -top {top_module}\n" \
                 f"proc; opt; fsm; opt; memory; opt\ntechmap; opt\nabc -liberty {lib_path}\nflatten\n" \
                 f"read_liberty -lib {lib_path}\nopt_clean -purge\nltp\nstat -liberty {lib_path}\n"
    
    with open(ys_path, "w") as f: f.write(ys_content)
    result = subprocess.run(['yosys', '-s', ys_path], capture_output=True, text=True)
    return parse_stats(result.stdout + result.stderr)

def main():
    top = "RCA8"
    optimization_log = {} # 用于存储最终导出的 JSON 数据

    for mode_id, config in MODES.items():
        print(f"\n==== RUNNING MODE {mode_id}: {config['desc']} ====")
        history = []
        mode_results = [] # 记录当前模式的每一步
        best_in_mode = {'logic_levels': 999, 'area_um2': 999.0}
        
        # 初始请求
        history.append({'role':'user', 'content': f"Propose an 8-bit adder for {config['desc']}."})
        
        for i in range(1, 11): # max_iter=10
            print(f"  [Iter {i}] Calling LLM...")
            try:
                response = client.chat.completions.create(
                    model=MODEL_NAME, 
                    messages=[{'role':'system','content':get_system_prompt(config)}] + history
                )
                verilog = response.choices[0].message.content.strip()
                verilog = re.sub(r"```verilog|```", "", verilog).strip()
                verilog = re.sub(r"module\s+\w+", f"module {top}", verilog, count=1)
                
                fname = f"mode_{mode_id}_iter_{i}.v"
                with open(fname, 'w') as f: f.write(verilog)
                
                ppa = synthesize(fname, top)
                
                # 存入 Log 数据结构
                iter_data = {
                    "iteration": i,
                    "area": ppa['area_um2'],
                    "levels": ppa['logic_levels'],
                    "cells": ppa['cell_count'],
                    "status": "success" if ppa['cell_count'] > 0 else "syntax_error"
                }
                mode_results.append(iter_data)
                
                if ppa['cell_count'] > 0:
                    print(f"    >> Area: {ppa['area_um2']} | Levels: {ppa['logic_levels']}")
                    # 更新最佳设计逻辑
                    if ppa['logic_levels'] < best_in_mode['logic_levels']:
                        best_in_mode = ppa
                        shutil.copy(fname, f"best_design_Mode_{mode_id}.v")
                
                # 更新对话历史
                history.append({'role':'assistant', 'content': verilog})
                history.append({'role':'user', 'content': f"Result: Area {ppa['area_um2']}, Levels {ppa['logic_levels']}. Keep optimizing."})
                
            except Exception as e:
                print(f"    >> Error: {e}")
                mode_results.append({"iteration": i, "status": "error", "message": str(e)})

        # 将当前模式的所有结果存入总 Log
        optimization_log[mode_id] = mode_results

    # 最终导出 JSON 文件
    with open("optimization_log.json", "w") as jf:
        json.dump(optimization_log, jf, indent=4)
    
    print("\n" + "="*40)
    print("✅ all modes done！")
    print("📂 files generated: optimization_log.json")
    print("📂 best design saved: best_design_Mode_*.v")
    print("="*40)

if __name__ == "__main__":
    main()