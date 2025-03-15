# EEC 201 WQ 25 Final Project: Speaker Recognition

## Team Name: The FFT Fighters
## Members: Roland Gadbois and Adam Ashkenazi

## Overview
The goal of the project is to recognize particular speakers given a sample set of multiple speakers. The code gets trained on the set once and can produce a classification for each speaker in the set.
We have tested our algorithm with multiple data sets of speakers saying: "Zero", "Twelve", "Eleven," and "Five". The highest speaker recognition accuracy we have achieved for a given word is 100%. The recognition method we have used is based on Mel-Frequency-Cepstrum-Coefficients (MFCC) and Vector Quantization (VQ). We extract the features from each speaker sample in the data set using MFCC and develop a codebook using the LBG algorithm for VQ. Speaker samples are recognized by comparing the MFCC of the sample to the samples in the codebook.

![speaker-recognition-overview](https://github.com/user-attachments/assets/5cac74ff-e180-46b5-9d3f-4eb4098a44b6)


## Pre-processing
To make the data easier to process, we perform the following pre-processing steps in this order:
* Remove the mean: we demean the data because the mean doesn't contain useful features for recognizing the speaker
* Normalize the data: divide each sample by the maximum signal value to normalize data across different volume levels
* Cut out zero samples: these samples don't provide useful information about the speaker

We perform these steps so that we can focus our feature extraction on normalized data across all speakers. In order to understand the effect of pre-processing on our signal analysis, let us look at how each of these pre-processing steps change the time spectra of a spoken word "zero". Firstly, as a point of comparison, we consider the "zero" sample without any pre-processing:
![TimeDomainZeroWithoutPreprocessing](https://github.com/user-attachments/assets/ac92a554-f4e9-4d3f-bd94-56aa3e217984)

We next demean the signal. While it visually does not change the time domain signal very much, it is a useful step before preparing to cut out zero samples as we found that some speech samples may have a slight offset compared to others, making it difficult to threshold at a constant amplitude across all samples in order to remove ambient silense before and after a spoken word:
![TimeDomainZeroAfterDemeaning](https://github.com/user-attachments/assets/d199685b-d75a-4f5b-9d8b-2380742518ab)

After demeaning, we normalize the data in order to avoid any biasing in classification with regards to a speaker's volume. For example, if we were to not have normalized our data, we may capture the speaker's volume as an important feature, such that two distinct speakers may be lumped together simply because they spoke at the same volume:
![TimeDomainZeroAfterNormalization](https://github.com/user-attachments/assets/2fd9cfad-d0f9-4986-abf9-843f1c2f0f93)

Finally, we cut out the zero samples, which focuses our classification on only the critical voiced sounds in the speech sample. This is a critical step in pre-processing because, as we found during implementation, the amount of silence in a recording can be seen as a feature. For example, we found while testing that in the training set, if one speech sample was left uncut, and the test samples also did not have their zero values removed, then the test samples were more likely to be classified to the uncut training sample than any other. 
![TimeDomainZeroAfterZeroCutting](https://github.com/user-attachments/assets/592569b1-a62d-489f-8b1e-a8677873a84f)
 

## Feature Extraction - MFCC
We cannot simply compare the waveforms of speaker samples to achieve good recognition results. The speaker may repeat the word more quickly, speak louder, or emphasize different parts of the word, resulting in different waveforms. Therefore, we will use an algorithm to extract the key features of each speaker sample. In this project, we use MFCC to extract valuable features for speaker recognition. The Mel-Frequency spectrum is a frequency scale that is linear from 0 - 1 kHz and logarithmically spaced above 1 kHz. It is meant to mimic the way human ears respond to different frequencies. Below is a diagram showing the datapath for extracting MFCC.

![mfcc-processor](https://github.com/user-attachments/assets/f52e9270-4773-45bc-8d6c-0f3f81f75e49)

The processing was done using frame blocking of varying lengths N = 128,256,512 and M = round(N/3) with an overlap of N - M and a hamming window of length N. We use the signal frames to construct a periodogram. When constructing the periodogram, we can visualize how the choice of N can affect frequency resolution:
![image (2)](https://github.com/user-attachments/assets/abd3089b-7c0d-4008-8c8e-88a11da70359)

Visualizing the periodograms can also reinforce why observing the speech samples in the frequency domain provides a far superior way to speaker identification than time-domain analysis as we as humans can even visually begin to pick out differences in speech. For example, let us compare the periodograms of four different spoken words: "zero", "five", "eleven", and "twelve":

![image (5)](https://github.com/user-attachments/assets/4c41409c-998c-40b6-9d67-515e56e994cb)

Words are comprised of voiced and unvoiced sounds. Voiced sounds are prominent in the spectrogram where as unvoiced sounds show up as white noise (flat spectrum). We can see that in the "Zero" spectrogram, there are high frequencies at the beginning of the word and low frequencies at the end, corresponding to the "e" and "o" voiced sounds. In the "five" spectrogram, we see in the beginning that the spectrum is low and flat corresponding to the unvoiced sound "f". We then see one prominet section of the sepctrogram corresponding to the "i" voiced sound. In the "eleven" spectrogram, we don't see white noise sections because the word mostly comprises voiced sounds. In the "twelve" spectrogram, we see similarities with "five" because both words start with unvoiced sounds.

Then, we perform mel warping on each frame of the signal. We filter each frame using 20 triangle bandpass filters spaced according to the mel-frequency scale, as can be seen below:
![MelSpacedFilterBank](https://github.com/user-attachments/assets/bc7dae71-5d45-40e7-a8eb-eed19b86fbcd)

Next, we add all the signal values in the frequency domain for a particular filter, resulting in 20 coefficients. Lastly, we take the log of the magnitude squared of the coefficients in frequency and convert them back to time using the Discrete Cosine Transform (DCT). The resulting coefficients are known as the Mel-Frequency-Cepstrum-Coefficients.

## Vector Quantization using the LBG Algorithm
The LBG algorithm finds clusters of data in an N dimensional space. We use this algorithm to cluster our data for classification. Each cluster is defined by a centroid, and a set of centroids constitute a "code" in a "codebook". Each speaker signal has been divided into frames from which we extracted MFCCs. We use the MFCCs as points in our vector quantization. We recognize a particular speaker by calculating the average distance of each set of points from each speaker to each code and choosing the code with the smallest average distance. That code corresponds to the selected speaker. Here's an example of clustering in two dimensions.

![image](https://github.com/user-attachments/assets/3400faac-69eb-47aa-99a3-d348bd86e2bf)

## Results
We tested our speaker recognition across multiple data sets. Each data set was used twice, once for training and once for testing. We used data sets of speakers saying the words "Zero", "Five", "Eleven", and "Twelve". We were given a dataset of speakers saying "Zero" to use as a baseline. The "Five" and "Eleven" datasets are samples that were recorded from students in class. We were given additional data from last year's class of speakers saying "Zero" and "Twelve".

Before building and testing our algorithm, we tried to recognize the speakers ourselves from the baseline data. The highest accuracy we achieved was 25%.

The first data set we examine is the baseline data of speakers saying "Zero" that was given in the assignment. Here's a table summarizing our accuracy results with different values for N (the frame length) and M (the codebook size).

| N\M        |   8      |   16     |   32     |  64     | 
|------------|----------|----------|----------|---------|
| 128        |  100%    |  100%    |  100%    | 100%    |
| 256        |  100%    |  100%    |  100%    | 100%    |
| 512        |  100%    |  87.5%   |  87.5%   | -       |

The accuracy for the baseline data without pre-processing is 75%. Therefore, the pre-processing steps we took significantly helped our accuracy, so the subsequent data was taken with pre-processing.

Here are the results for "Five" from last year's class.

| N\M        |   8      |   16     |   32     |  64     | 
|------------|----------|----------|----------|---------|
| 128        |  87.0%   |  87.0%   |  91.3%   | 91.3%   |
| 256        |  95.6%   |  95.6%   |  95.6%   | 95.6%   |
| 512        |  95.6%   |  95.6%   |  95.6%   | 95.6%   |

Here are the results for "Eleven" from last year's class.

| N\M        |   8      |   16     |   32     |  64     | 
|------------|----------|----------|----------|---------|
| 128        |  78.3%   |  87.0%   |  87.0%   | 87.0%   |
| 256        |  100%    |  100%    |  100%    | 100%    |
| 512        |  100%    |  100%    |  100%    | 100%    |

Here are the results for "Zero" from this year's class.

| N\M        |   8      |   16     |   32     |  64     | 
|------------|----------|----------|----------|---------|
| 128        |  83.3%   |  83.3%   |  88.9%   | 94.4%   |
| 256        |  88.9%   |  94.4%   |  100%    | 100%    |
| 512        |  88.9%   |  100%    |  100%    | 100%    |

Here are the results for "Twelve" from this year's class.

| N\M        |   8      |   16     |   32     |  64     | 
|------------|----------|----------|----------|---------|
| 128        |  88.9%   |  94.4%   |  94.4%   | 88.9%   |
| 256        |  94.4%   |  100%    |  100%    | 100%    |
| 512        |  94.4%   |  100%    |  100%    | 100%    |

We suspect we achieved lower accuracies for "Five" compared to "Zero" and "Eleven" because "Five" only has one voiced sound, whereas "Zero" and "Eleven" have two. Voiced sounds give us more useful features for the speaker and, therefore, the recognition is better. The accuracy for "Twelve" is quite high for the same reason.

## Contributions
Roland and I met after class several times to break down the tasks and algorithm and record our accuracies. Roland wrote most of the Matlab code because he was familiar with the language, and I wrote more of the report.


