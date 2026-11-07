[file, path] = uigetfile('*.wav', '读取录音文件');
filename = fullfile(path, file);
[data, fs] = audioread(filename);
% 滤波前的音频信号
original_data = data;  % 假设 `data` 为原始音频信号

%{
lowcut = 2000; 
highcut = 20000; 
order = 3; 

[b, a] = butter(order, [lowcut highcut] / (fs / 2), 'bandpass');
%这里使用的是5阶的 Butterworth 带通滤波器 属于(IIR滤波器)
filtered_data = filter(b, a, data);
%}

count=0;

Fp = [2000 20000];  % 通带频率范围 (2-20 kHz)
Fs = [1500 21000]; % 阻带频率范围 (1.5-21 kHz)
Rp = 0.3;          % 通带最大允许衰减 (dB)
Rs = 50;           % 阻带最小衰减 (dB)
order = 5;         % 滤波器的阶数(5阶)

% 归一化频率，除以 (fs / 2)
Wp = Fp / (fs / 2); % 通带频率归一化
Ws = Fs / (fs / 2); % 阻带频率归一化

% 使用椭圆带通滤波器
[b, a] = ellip(order, Rp, Rs, Wp, 'bandpass');


% 进行滤波操作
filtered_data = filter(b, a, data);

frame_size = 960; 
frame_shift = 480;

num_frames = floor((length(filtered_data) - frame_size) / frame_shift) + 1;
frames = zeros(frame_size, num_frames);

time = (0:length(filtered_data)-1) / fs;
frame_time = (0:num_frames-1) * frame_shift / fs;

threshold_energy_min = 1e-10;
threshold_energy_max = 2e-4;

time_start = 149.8;
time_end = 149.82;

%threshold_energy_min = 2e-8;
%threshold_energy_max = 1e-4;

threshold_zcr_min = 0.1;
threshold_zcr_max =0.3;

figure;
plot(time, filtered_data);
title('Time Domain Signal of Shrimp Sound (Filtered)');
xlabel('Time [s]');
ylabel('Amplitude');
xlim([time_start time_end]);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
grid on;


for i = 1:num_frames
start_index = (i-1) * frame_shift + 1;
frames(:, i) = filtered_data(start_index:start_index+frame_size-1);
end

short_time_energy = sum(frames.^2) / frame_size;
% 改进后的 ZCR 计算方法：检测真正的过零点（相邻点符号变化）
zcr = sum(frames(1:end-1, :) .* frames(2:end, :) < 0) / frame_size;


voice_flags = (short_time_energy > threshold_energy_min & short_time_energy<threshold_energy_max) & (zcr > threshold_zcr_min );

% 计算前5ms和后15ms对应的样本数
pre_samples = round(0.005 * fs);   % 前5ms的样本数
post_samples = round(0.015 * fs);  % 后15ms的样本数

% 初始化新的音频数据数组
new_audio_data = [];

% 找到连续发声区域的起始和结束帧索引
voice_diff = diff([0; voice_flags(:); 0]);  % 在voice_flags前后添加0，以捕捉边界
start_indices = find(voice_diff == 1);   % 发声开始的帧索引
end_indices = find(voice_diff == -1) - 1; % 发声结束的帧索引

% % 处理每个发声区域
% for idx = 1:length(start_indices)
%     count = count + 1;
%     
%     % 获取当前发声区域的起始和结束帧
%     start_frame = start_indices(idx);
%     end_frame = end_indices(idx);
%     
%     % 将帧索引转换为采样点索引
%     start_sample = (start_frame - 1) * frame_shift + 1;
%     end_sample = (end_frame - 1) * frame_shift + frame_size;
%     
%     % 扩展发声区域的起始和结束位置，考虑前后延伸
%     extended_start = max(1, start_sample - pre_samples);
%     extended_end = min(length(filtered_data), end_sample + post_samples);
%     
%     % 提取并保存音频段
%     new_audio_data = [new_audio_data; filtered_data(extended_start:extended_end)];
% end

% 如果需要，可以保存新的音频文件
audiowrite('new_audio.wav', new_audio_data, fs);

% 计算新音频的时间轴
new_time = (0:length(new_audio_data)-1) / fs;


%绘制新音频的时间域信号
figure;
plot(new_time, new_audio_data);
title('Time Domain Signal of Extracted Shrimp Sounds');
xlabel('Time [s]');
ylabel('Amplitude');
xlim([0.087 0.098]);  
grid on;

window_size = 256;
noverlap = 128;
nfft = 512;

%{
figure;
spectrogram(filtered_data, window_size, noverlap, nfft, fs, 'yaxis');
title('Spectrogram of Shrimp Sound (Filtered)');
xlabel('Time [s]');
ylabel('Frequency [kHz]');
xlim([time_start time_end]);  
ylim([0 40]); 
colorbar;
caxis([0, 60]);
%}


figure;
subplot(4,1,1);
plot(time, filtered_data);
title('Filtered Speech Signal');
xlabel('Time [s]');
ylabel('Amplitude');


subplot(4,1,2);
plot(frame_time, short_time_energy);
title('Short-Time Energy');
xlabel('Time [s]');
ylabel('Energy');

subplot(4,1,3);
plot(frame_time, zcr);
title('Short-Time Zero Crossing Rate');
xlabel('Time [s]');
ylabel('ZCR');

subplot(4,1,4);
plot(frame_time, voice_flags);
title('Voice Activity Detection');
xlabel('Time [s]');
ylabel('Speech Flag');

ylim([-0.1, 1.1]);


figure;
% 第一张图：原始数据的时间域信号
subplot(2, 1, 1);  % 将第一张图放在2行1列布局的第1个位置
plot(time, original_data);
title('Time Domain Signal of Shrimp Sound (Original)');
xlabel('Time [s]');
ylabel('Amplitude');
xlim([0 120]);
grid on;

% 第二张图：滤波后的数据的时间域信号
subplot(2, 1, 2);  % 将第二张图放在2行1列布局的第2个位置
plot(time, filtered_data);
title('Time Domain Signal of Shrimp Sound (Filtered)');
xlabel('Time [s]');
ylabel('Amplitude');
xlim([0 120]);
grid on;
% 总标题
sgtitle('Comparison of Original and Filtered Shrimp Sound');


fft_data = fft(filtered_data);
freqs = (0:length(fft_data)-1) * (fs / length(fft_data));
magnitude = abs(fft_data);

figure;
plot(freqs(1:length(freqs)/2), magnitude(1:length(magnitude)/2));
title('Frequency Domain Signal of Shrimp Sound');
xlabel('Frequency [Hz]');
ylabel('Magnitude');
grid on;
