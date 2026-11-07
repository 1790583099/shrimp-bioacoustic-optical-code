import matplotlib.pyplot as plt
import numpy as np
from matplotlib.font_manager import FontProperties

# 设置中文字体
plt.rcParams['font.sans-serif'] = ['SimHei']  # 使用黑体
plt.rcParams['axes.unicode_minus'] = False  # 解决负号显示问题

# # 数据准备
# time_intervals = ['5min', '5min', '10min', '10min', '30min', '30min']
# x_ticks = ['5min\n(1)', '5min\n(2)', '10min\n(1)', '10min\n(2)', '30min\n(1)', '30min\n(2)']
#
# signal_percent = [11.4, 10.9, 9.7, 12.2, 12.8, 11.3]
# individual_percent = [9.6, 9.6, 11.5, 9.6, 11.5, 13.4]
#
# x = np.arange(len(time_intervals))  # x轴位置
#
# # 创建图表
# plt.figure(figsize=(10, 6))
#
# # 绘制两条折线
# plt.plot(x, signal_percent, marker='o', label='虚弱声音信号占比', color='blue')
# plt.plot(x, individual_percent, marker='s', label='虚弱个体数目占比', color='red')
#
# # 添加标题和标签
# plt.title('各时间段虚弱信号与虚弱个体占比对比', fontsize=14)
# plt.xlabel('时间段', fontsize=12)
# plt.ylabel('百分比 (%)', fontsize=12)
# plt.xticks(x, x_ticks)
# plt.ylim(8, 15)  # 设置y轴范围
#
# # 添加数据标签
# for i, (sig, ind) in enumerate(zip(signal_percent, individual_percent)):
#     plt.text(i, sig+0.2, f'{sig}%', ha='center', color='blue')
#     plt.text(i, ind+0.2, f'{ind}%', ha='center', color='red')
#
# # 添加图例和网格
# plt.legend(loc='upper right')
# plt.grid(True, linestyle='--', alpha=0.5)
#
# # 显示图表
# plt.tight_layout()
# plt.savefig('虚弱信号对比图.png', dpi=300, bbox_inches='tight')
# plt.show()


# 数据准备
time_intervals = ['5min', '5min', '10min', '10min', '30min', '30min']
x_ticks = ['5min\n(1)', '5min\n(2)', '10min\n(1)', '10min\n(2)', '30min\n(1)', '30min\n(2)']

signal_percent = [11.4, 10.9, 9.7, 12.2, 12.8, 11.3]
individual_percent = [9.6, 9.6, 11.5, 9.6, 11.5, 13.4]

# 计算差值
differences = [sig - ind for sig, ind in zip(signal_percent, individual_percent)]

x = np.arange(len(time_intervals))  # x轴位置

# 创建图表
plt.figure(figsize=(10, 6))

# 绘制柱形图
bars = plt.bar(x, differences, color=['skyblue' if diff > 0 else 'salmon' for diff in differences])

# 添加标题和标签
plt.title('各时间段虚弱信号占比与虚弱个体占比差值(以声音信号为基准)', fontsize=14)
plt.xlabel('时间段', fontsize=12)
plt.ylabel('差值 (%)', fontsize=12)
plt.xticks(x, x_ticks)

# 添加数据标签
for i, diff in enumerate(differences):
    color = 'blue' if diff > 0 else 'red'
    plt.text(i, diff + 0.1 if diff > 0 else diff - 0.3,
             f'{diff:.1f}%',
             ha='center',
             color=color,
             fontweight='bold')

# 添加参考线
plt.axhline(y=0, color='gray', linestyle='--', linewidth=0.8)

# 添加图例
plt.legend([plt.Rectangle((0,0),1,1,fc='skyblue'), plt.Rectangle((0,0),1,1,fc='salmon')],
           ['正向', '反向'],
           loc='upper right')

# 调整y轴范围
y_min = min(differences) - 1
y_max = max(differences) + 1
plt.ylim(y_min, y_max)

# 添加网格
plt.grid(True, axis='y', linestyle='--', alpha=0.5)

# 显示图表
plt.tight_layout()
plt.savefig('虚弱信号差值对比图.png', dpi=300, bbox_inches='tight')
plt.show()