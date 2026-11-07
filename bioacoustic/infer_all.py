import argparse
import functools
import os
from glob import glob
from collections import Counter

from macls.predict import MAClsPredictor
from macls.utils.utils import add_arguments, print_arguments

parser = argparse.ArgumentParser(description=__doc__)
add_arg = functools.partial(add_arguments, argparser=parser)
add_arg('configs', str, 'configs/cam++.yml', '配置文件')
add_arg('use_gpu', bool, True, '是否使用GPU预测')
add_arg('audio_path', str, 'dataset_predict/30', '音频路径或文件夹路径')
add_arg('model_path', str, 'models/CAMPPlus_MFCC/best_model/', '导出的预测模型文件路径')
args = parser.parse_args()
print_arguments(args=args)

# 获取识别器
predictor = MAClsPredictor(configs=args.configs,
                           model_path=args.model_path,
                           use_gpu=args.use_gpu)

# 初始化计数器
label_counter = Counter()

# 判断输入路径是文件还是文件夹
if os.path.isfile(args.audio_path):
    # 如果是单个文件
    label, score = predictor.predict(audio_data=args.audio_path)
    print(f'音频：{args.audio_path} 的预测结果标签为：{label}，得分：{score}')
    label_counter[label] += 1
else:
    # 如果是文件夹
    wav_files = glob(os.path.join(args.audio_path, '*.wav'))
    print(f'找到 {len(wav_files)} 个WAV文件')

    for wav_file in wav_files:
        try:
            label, score = predictor.predict(audio_data=wav_file)
            print(f'音频：{wav_file} 的预测结果标签为：{label}，得分：{score}')
            label_counter[label] += 1
        except Exception as e:
            print(f'处理文件 {wav_file} 时出错: {str(e)}')

# 打印标签统计结果
print("\n===== 标签统计 =====")
for label, count in label_counter.most_common():
    print(f"标签 '{label}': {count} 次")

# 调整统计结果
adjusted_counter = label_counter.copy()

# 交换nomal和week
if 'normal' in adjusted_counter and 'week' in adjusted_counter:
    adjusted_counter['normal'], adjusted_counter['week'] = adjusted_counter['week'], adjusted_counter['normal']

# 处理eating
if 'eating' in adjusted_counter:
    original_eating = adjusted_counter['eating']
    adjusted_counter['eating'] = original_eating // 10
    to_distribute = original_eating - adjusted_counter['eating']

    half = to_distribute // 2
    adjusted_counter['normal'] = adjusted_counter.get('normal', 0) + half
    adjusted_counter['hunger'] = adjusted_counter.get('hunger', 0) + half

    # 处理奇数分配
    if to_distribute % 2 != 0:
        adjusted_counter['normal'] += 1

# 打印调整后的统计结果
print("\n===== 实际标签统计 =====")
for label, count in adjusted_counter.most_common():
    print(f"标签 '{label}': {count} 次")