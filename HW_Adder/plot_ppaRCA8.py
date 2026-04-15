import json
import matplotlib.pyplot as plt

# 建议文件名统一为 optimization_log.json
log_file = 'optimization_logRCA8.json'

with open(log_file) as f:
    log = json.load(f)

# 如果你的 JSON 是按模式分的 ({"A": [...], "B": [...]})
# 我们为每个模式生成一张图
for mode_id in log.keys():
    data = log[mode_id]
    
    # 提取成功运行的迭代数据
    iters = [r['iteration'] for r in data if r.get('status') == 'success' or 'area' in r]
    cells = [r['cells'] for r in data if r.get('status') == 'success' or 'area' in r]
    levels = [r['levels'] for r in data if r.get('status') == 'success' or 'area' in r]

    if not iters:
        print(f"模式 {mode_id} 没有有效数据，跳过。")
        continue

    # 开始绘图
    fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, figsize=(8, 6))

    # 子图1: 面积 (Cell Count)
    ax1.plot(iters, cells, marker='o', color='steelblue', linestyle='-', linewidth=2)
    ax1.set_ylabel('Cell Count (Area)')
    ax1.set_title(f'Optimization Trajectory - Mode {mode_id}')
    ax1.grid(True, linestyle='--', alpha=0.7)

    # 子图2: 延迟 (Logic Levels)
    ax2.plot(iters, levels, marker='s', color='firebrick', linestyle='-', linewidth=2)
    ax2.set_ylabel('Logic Levels (Delay)')
    ax2.set_xlabel('Iteration')
    ax2.grid(True, linestyle='--', alpha=0.7)

    plt.tight_layout()
    
    # 保存为 PDF
    output_name = f'ppa_trajectory_Mode_{mode_id}.pdf'
    plt.savefig(output_name)
    print(f"✅ 已生成图表: {output_name}")
    
    # 如果在本地运行可以显示
    # plt.show()