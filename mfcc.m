function [f,t, mfcc] = mfcc(x,fs,N)
M = round(N/3);
[s, f, t] = spectrogram(x, hamming(128, 'periodic'), N - M, N, fs);
m = melfb_own(20, N, fs);
mel_spectrum = m * abs(s).^2;
mfcc = dct(log10(max(mel_spectrum,1e-10)));
end