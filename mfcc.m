[x,fs]=audioread('Test_Data\s1.wav');
sound(x);

fs = 12500

% 20.48 milliseconds are contained in a block of 256 samples.

time_axis = (0:length(x)-1) / fs;
plot(time_axis, x);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Signal in Time Domain');
time_axis = (0:length(x)-1) / fs;
plot(time_axis, x);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Time Spectra');
xlim([0, 1])


[S, F, T] = spectrogram(x, 128, 128-43, 43, fs);
imagesc(T * 1000, F, abs(S));
axis xy;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');

mel_filter_bank = melfb_own(20, 128, fs);
