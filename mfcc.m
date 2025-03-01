[x,fs]=audioread('Test_Data\s1.wav');
sound(x);

%fs = 12500

% 20.48 milliseconds, contained in a block of 256 samples.

time = (0:length(x)-1) / fs;
plot(time, x);
xlabel('Time (seconds)');
ylabel('Amplitude');
title('Time Spectra');

N = 128;
M = round(N/3);

[s, f, t] = spectrogram(x, hamming(128, 'periodic'), N - M, N, fs);
imagesc(t * 1000, f, abs(s));
axis xy;
xlabel('Time (ms)');
ylabel('Frequency (Hz)');
colorbar;

m = melfb_own(20, N, fs);

plot(linspace(0, (fs/2), N/2 + 1), melfb_own(20, N, fs)'),
title('Mel-spaced filterbank'), xlabel('Frequency (Hz)');

mel_spectrum = m * abs(s).^2;
mfcc = dct(log10(mel_spectrum));
imagesc(t, [1, 20], mfcc);
axis xy;
