% A MATLAB script to implement a brute force method to score the plagiarism
% detected between two pieces of music. The algorithm used is one mentioned
% on the EUSIPCO paper: AUDIO FORENSICS MEETS MUSIC INFORMATION RETRIEVAL -
% A TOOLBOX FOR INSPECTION OF MUSIC PLAGIARISM by Christian Dittmar et al.

[data_orig,fs] = audioread('0b_Original_Sample.wav');
[data_copy,fs] = audioread('0a_Suspected_Plagiarism.wav');

%% initializiting parameters

fs = 44100;
fmin = 27.5;
B = 48;
gamma = 20;
fmax = fs/2;

%% Computing the constant Q transforms
Xo = cqt(data_orig, B, fs, fmin, fmax, 'rasterize', 'none', 'gamma', gamma);
Xs = cqt(data_copy, B, fs, fmin, fmax, 'rasterize', 'none', 'gamma', gamma);

