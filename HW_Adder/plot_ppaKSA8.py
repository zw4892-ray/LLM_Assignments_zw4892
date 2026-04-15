import re
import matplotlib.pyplot as plt

# 1. 设置你的日志文件名
log_file = 'optimization_logKSA8.json' 

def parse_and_plot():
    try:
        with open(log_file, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"❌ 找不到文件: {log_file}")
        return

    # 2. 按模式（Mode）分割日志
    modes = re.split(r'={20,}', content)
    
    # 结果存储
    results = {}

    current_mode = None
    for part in modes:
        # 匹配模式名称 (A, B, 或 C)
        mode_match = re.search(r'STARTING MODE ([ABC]):', part)
        if mode_match:
            current_mode = mode_match.group(1)
            results[current_mode] = {'iters': [], 'area': [], 'levels': []}
            continue
        
        if current_mode:
            # 提取每一个 Iteration 的数据
            # 匹配类似: [Mode B - Iter 10] ... >> Area: 55.594 | Levels: 5
            iters_data = re.findall(r'Iter (\d+)\].*?Area: ([\d.]+)\s*\|\s*Levels: (\d+)', part, re.DOTALL)
            for it, area, lvl in iters_data:
                results[current_mode]['iters'].append(int(it))
                results[current_mode]['area'].append(float(area))
                results[current_mode]['levels'].append(int(lvl))

    # 3. 绘图
    for mode_id, data in results.items():
        if not data['iters']:
            continue
            
        print(f"正在绘制模式 {mode_id} 的图表...")
        fig, (ax1, ax2) = plt.subplots(2, 1, sharex=True, figsize=(10, 8))

        # 子图1: Area
        ax1.plot(data['iters'], data['area'], marker='o', color='tab:blue', linewidth=2, label='Area')
        ax1.set_ylabel('Area (um^2)')
        ax1.set_title(f'PPA Optimization Trajectory - Mode {mode_id}')
        ax1.grid(True, linestyle='--', alpha=0.7)

        # 子图2: Logic Levels
        ax2.plot(data['iters'], data['levels'], marker='s', color='tab:red', linewidth=2, label='Levels')
        ax2.set_ylabel('Logic Levels (Delay)')
        ax2.set_xlabel('Iteration')
        ax2.grid(True, linestyle='--', alpha=0.7)

        plt.xticks(data['iters'])
        plt.tight_layout()
        
        # 保存 PDF
        output_name = f'ppa_trajectory_KSA8_Mode_{mode_id}.pdf'
        plt.savefig(output_name)
        print(f"✅ 已生成: {output_name}")

if __name__ == "__main__":
    parse_and_plot()