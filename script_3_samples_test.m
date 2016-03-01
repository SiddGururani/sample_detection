%1 Sample kept the same. Suspect time stretched
sample_no = 1;
sample = '../Audio/sample.aif';
suspect_no = 1;
suspect = '../Audio/suspect.aif';
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

suspect_no = 2;
suspect = '../Audio/time.wav';
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

suspect_no = 3;
suspect = '../Audio/0a_Suspected_Plagiarism.wav';
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

%2 Sample time stretched. Suspect kept the same
sample_no = 2;
sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/01.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';
suspect_no = 1;
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/Time-stretched/01.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';
suspect_no = 2;
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/01.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
suspect_no = 3;
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

%3 Sample time stretched. Suspect kept the same
sample_no = 3;
sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/02.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
suspect_no = 1;
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/Time-stretched/02.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
suspect_no = 2;
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/02.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';
suspect_no = 3;
[result, locs] = time_stretch(sample, suspect, sample_no, suspect_no);
fprintf('Sample# %d vs Suspect# %d: %d\n',sample_no, suspect_no, result);

% sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/02.wav';
% sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/Time-stretched/02.wav';
% suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
% suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';