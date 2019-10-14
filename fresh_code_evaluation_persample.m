clc;
annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Mat/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Mat/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';

annotation = csvread(annotation_file);

% dists = cell(1,80);
features = cell(80,20);
activation_pairs_mod = cell(80,20);
songs_checked = [];
for sample_num = 50:59
    tic;
if(annotation(sample_num,1) < 10)
   filenum1 = ['0',num2str(annotation(sample_num,1))];
else
   filenum1 = num2str(annotation(sample_num,1));
end
% [sample,fs1] = audioread([sample_dir, filenum1,'.mp3']);
S = load([sample_dir, filenum1,'.mat']);
sample = S.sample;
fs1 = S.fs1;
clear S;
sample = sample(ceil(fs1*annotation(sample_num,3)):ceil(fs1*annotation(sample_num,4)),:);

if(annotation(sample_num,2) < 10)
   filenum2 = ['0',num2str(annotation(sample_num,2))];
else
   filenum2 = num2str(annotation(sample_num,2));
end

songs = annotation(:,2)';
songs(songs == str2num(filenum2)) = [];
songs_to_check = [str2num(filenum2),randsample(songs,9)];

    for i = 1:1
        if(songs_to_check(i) < 10)
           filenum2 = ['0',num2str(songs_to_check(i))];
        else
           filenum2 = num2str(songs_to_check(i));
        end 
        
%         [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
        S = load([suspect_dir, filenum2,'.mat']);
        suspect = S.suspect;
        fs2 = S.fs2;
        clear S;

        if(fs1 > 22050)
            sample = downsample(sample,fs1/22050);
            sample = sample/rms(sample);
            fs1 = 22050;
        end
        if(fs2 > 22050)
            suspect = downsample(suspect,fs2/22050);
            suspect = suspect/rms(suspect);
            fs2 = 22050;
        end
        disp(['Sample:',num2str(sample_num),'   Song:',num2str(filenum2)])
        [activation_pairs_mod{sample_num,i}] = extract_activations_mod(sample,suspect,10,20);
        [features{sample_num, i}] = extract_dtw_features(activation_pairs_mod{sample_num,i}.sample_H,activation_pairs_mod{sample_num,i}.suspect_H, 'correlation');
    end
    toc
    songs_checked = [songs_checked;songs_to_check];
end