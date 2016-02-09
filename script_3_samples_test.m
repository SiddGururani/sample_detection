%1 Sample kept the same. Suspect time stretched
sample_no = 1;
sample = '../Audio/sample.aif';
suspect_no = 1;
suspect = '../Audio/suspect.aif';
time_stretch(sample, suspect, sample_no, suspect_no)

suspect_no = 2;
suspect = '../Audio/time.wav';
time_stretch(sample, suspect, sample_no, suspect_no)

suspect_no = 3;
suspect = '../Audio/0a_Suspected_Plagiarism.wav';
time_stretch(sample, suspect, sample_no, suspect_no)

%2 Sample time stretched. Suspect kept the same
sample_no = 2;
sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/01.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';
suspect_no = 1;
time_stretch(sample, suspect, sample_no, suspect_no)

sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/Time-stretched/01.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';
suspect_no = 2;
time_stretch(sample, suspect, sample_no, suspect_no)

sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/01.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
suspect_no = 3;
time_stretch(sample, suspect, sample_no, suspect_no)

%3 Sample time stretched. Suspect kept the same
sample_no = 3;
sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/02.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
suspect_no = 1;
time_stretch(sample, suspect, sample_no, suspect_no)

sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/Time-stretched/02.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
suspect_no = 2;
time_stretch(sample, suspect, sample_no, suspect_no)

sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/02.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';
suspect_no = 3;
time_stretch(sample, suspect, sample_no, suspect_no)

% sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/02.wav';
% sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/Time-stretched/02.wav';
% suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
% suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';