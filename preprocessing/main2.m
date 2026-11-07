[file, path] = uigetfile('*.wav', '读取录音文件');
filename = fullfile(path, file);
[data, fs] = audioread(filename);
original_data = data;

% 滤波参数
Fp = [2000 20000];
Fs = [1500 21000];
Rp = 0.3;
Rs = 50; 
order = 5;

Wp = Fp / (fs / 2);
Ws = Fs / (fs / 2);

[b, a] = ellip(order, Rp, Rs, Wp, 'bandpass');
filtered_data = filter(b, a, data);

frame_size = 960;
frame_shift = 480;

num_frames = floor((length(filtered_data) - frame_size) / frame_shift) + 1;
frames = zeros(frame_size, num_frames);
time = (0:length(filtered_data)-1) / fs;
frame_time = (0:num_frames-1) * frame_shift / fs;

% VAD 阈值设定
threshold_energy_min = 1e-10;
threshold_energy_max = 2e-4;

threshold_zcr_min = 0.1;
threshold_zcr_max = 0.3;

for i = 1:num_frames
    start_index = (i-1) * frame_shift + 1;
    frames(:, i) = filtered_data(start_index:start_index+frame_size-1);
end

short_time_energy = sum(frames.^2) / frame_size;
zcr = sum(abs(diff(sign(frames)))) / (2 * frame_size);
voice_flags = (short_time_energy > threshold_energy_min & short_time_energy < threshold_energy_max) & (zcr > threshold_zcr_min);

% 延伸采样点数量
pre_samples = round(0.005 * fs);   % 前5ms
post_samples = round(0.015 * fs);  % 后15ms

new_audio_data = [];
voice_diff = diff([0; voice_flags(:); 0]);
start_indices = find(voice_diff == 1);
end_indices = find(voice_diff == -1) - 1;

count = 0;

for idx = 1:length(start_indices)
    count = count + 1;

    start_frame = start_indices(idx);
    end_frame = end_indices(idx);

    start_sample = (start_frame - 1) * frame_shift + 1;
    end_sample = (end_frame - 1) * frame_shift + frame_size;

    extended_start = max(1, start_sample - pre_samples);
    extended_end = min(length(filtered_data), end_sample + post_samples);

    new_audio_data = [new_audio_data; filtered_data(extended_start:extended_end)];
end

% % 保存提取后的整体音频段
% audiowrite('new_audio.wav', new_audio_data, fs);

% ================= 新增功能开始 =================

% % 创建文件夹保存每段0.1秒的音频
% output_folder = 'E:\声光联合数据集\30分钟_2';
% if ~exist(output_folder, 'dir')
%     mkdir(output_folder);
% end
% 
% segment_duration = 0.1; % 秒
% segment_samples = round(segment_duration * fs);
% half_segment = round(segment_samples / 2);
% 
% for idx = 1:length(start_indices)
%     center_sample = (start_indices(idx) - 1) * frame_shift + round(frame_size / 2);
% 
%     seg_start = max(1, center_sample - half_segment);
%     seg_end = min(length(filtered_data), center_sample + half_segment - 1);
% 
%     segment_data = filtered_data(seg_start:seg_end);
% 
%     % 补零（如果长度不足）
%     if length(segment_data) < segment_samples
%         segment_data = [segment_data; zeros(segment_samples - length(segment_data), 1)];
%     end
% 
%     segment_filename = fullfile(output_folder, sprintf('segment_%03d.wav', idx));
%     audiowrite(segment_filename, segment_data, fs);
% end

% ================= 新增功能结束 =================


%绘图相关
new_time = (0:length(new_audio_data)-1) / fs;
time_start = 42.106;
time_end = 42.128;

figure;
plot(time, filtered_data);
title('提取到的南美白对虾发声信号');
xlabel('时间[s]');
ylabel('幅值');
xlim([time_start time_end]);
grid on;

figure;
plot(new_time, new_audio_data);
title('提取到的南美白对虾发声信号');
xlabel('时间[s]');
ylabel('幅值');
xlim([0.087 0.098]);
grid on;

fft_data = fft(filtered_data);
freqs = (0:length(fft_data)-1) * (fs / length(fft_data));
magnitude = abs(fft_data);

figure;
plot(freqs(1:length(freqs)/2), magnitude(1:length(magnitude)/2));
title('Frequency Domain Signal of Shrimp Sound');
xlabel('Frequency [Hz]');
ylabel('Magnitude');
grid on;

window_size = 256;
noverlap = 128;
nfft = 512;

figure;
plot(time, filtered_data);
title('');
xlabel('时间[s]');
ylabel('幅值');
xlim([0 60]);
ylim([-0.0008,0.000801]);
grid on;

figure;
subplot(4,1,1);
plot(time, filtered_data);
title('时域信号波形');
xlabel('时间[s]');
ylabel('幅值');

subplot(4,1,2);
plot(frame_time, short_time_energy);
title('短时平均能量');
xlabel('Time [s]');
ylabel('幅值');

subplot(4,1,3);
plot(frame_time, zcr);
title('短时过零率');
xlabel('时间[s]');
ylabel('幅值');

subplot(4,1,4);
plot(frame_time, voice_flags);
title('发声帧检测');
xlabel('时间[s]');
ylabel('标志位');
ylim([-0.1, 1.1]);

figure;
subplot(2, 1, 1);
plot(time, original_data);
title('对虾声信号时域波形(滤波前)');
xlabel('时间[s]');
ylabel('幅值');
xlim([0 60]);
grid on;

subplot(2, 1, 2);
plot(time, filtered_data);
title('对虾声信号时域波形(滤波后)');
xlabel('时间[s]');
ylabel('幅值');
xlim([0 60]);
grid on;
sgtitle('滤波前后对比');



% fft_data = fft(filtered_data);
% freqs = (0:length(fft_data)-1) * (fs / length(fft_data));
% magnitude = abs(fft_data);
% 
% figure;
% plot(freqs(1:length(freqs)/2), magnitude(1:length(magnitude)/2));
% title('对虾声信号频域波形');
% xlabel('Frequency [Hz]');
% ylabel('Magnitude');
% grid on;
