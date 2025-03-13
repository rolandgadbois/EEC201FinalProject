# EEC 201 WQ 24 Final Project: Speaker Recognition

## Team Name: The FFT Fighters
## Members: Roland Gadbois and Adam Ashkenazi

## Overview
The goal of the project is to recognize particular speakers given a sample set of multiple speakers. The code gets trained on the set once and can produce a classification for each speaker in the set.
We have tested our algorithm with multiple data sets of speakers saying: "Zero", "Twelve", "Eleven," and "Five". The highest speaker recognition accuracy we have achieved for a given word is 87%. The recognition method we have used is based on Mel-Frequency-Cepstrum-Coefficients (MFCC) and Vector Quantization (VQ). We extract the features from each speaker sample in the data set using MFCC and develop a codebook using the LBG algorithm for VQ. Speaker samples are recognized by comparing the MFCC of the sample to the samples in the codebook.

![speaker-recognition-overview](https://github.com/user-attachments/assets/5cac74ff-e180-46b5-9d3f-4eb4098a44b6)


## Pre-processing
To make the data easier to process, we perform the following pre-processing steps:
* Cut out zero samples: these samples don't provide useful information about the speaker
* Remove the mean: we demean the data because the mean doesn't contain useful features for recognizing the speaker
* Normalize the data: divide each sample by the maximum signal value to normalize data across different volume levels

We perform these steps so that we can focus our feature extraction on normalized data across all speakers.

## Feature Extraction - MFCC
We cannot simply compare the waveforms of speaker samples to achieve good recognition results. The speaker may repeat the work more quickly, speak louder, or emphasize different parts of the word, resulting in different waveforms. Therefore, we will use an algorithm to extract the key features of each speaker sample. In this project, we use MFCC to extract valuable features for speaker recognition. The Mel-Frequency spectrum is a frequency scale that is linear from 0 - 1 kHz and logarithmically spaced above 1 kHz. It is meant to mimic the way human ears respond to different frequencies. Below is a diagram showing the datapath for extracting MFCC.

![mfcc-processor](https://github.com/user-attachments/assets/f52e9270-4773-45bc-8d6c-0f3f81f75e49)

The processing was done using frame blocking of length N = 128 and M = round(N/3) with an overlap of N - M and a hamming window. We use the signal frames to construct a periodogram.
Then, we perform mel warping on each frame of the signal. We filter each frame using 20 triangle bandpass filters spaced according to the mel-frequency scale. Next, we add all the signal values for a particular filter, resulting in 20 coefficients.
Lastly, we convert the mel coefficients back to time using the Discrete Cosine Transform (DCT). The resulting coefficients are known as the Mel-Frequency-Cepstrum-Coefficients.


