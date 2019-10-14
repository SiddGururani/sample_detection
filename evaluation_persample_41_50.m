annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';

annotation = csvread(annotation_file);

% dists = cell(1,80);
features = cell(80,20);
songs_checked = [];
for sample_num = 51:60
    sample_num
tic;
if(annotation(sample_num,1) < 10)
   filenum1 = ['0',num2str(annotation(sample_num,1))];
else
   filenum1 = num2str(annotation(sample_num,1));
end
[sample,fs1] = audioread([sample_dir, filenum1,'.mp3']);
sample = sample(ceil(fs1*annotation(sample_num,3)):ceil(fs1*annotation(sample_num,4)),:);

if(annotation(sample_num,2) < 10)
   filenum2 = ['0',num2str(annotation(sample_num,2))];
else
   filenum2 = num2str(annotation(sample_num,2));
end 

songs_to_check = [str2num(filenum2)];
songs = 1:80;
songs(find(songs == str2num(filenum2))) = [];

songs_to_check = [songs_to_check, randsample(songs,19)];

    for i = 1:20
        if(annotation(songs_to_check(i),2) < 10)
           filenum2 = ['0',num2str(annotation(songs_to_check(i),2))];
        else
           filenum2 = num2str(annotation(songs_to_check(i),2));
        end 
        [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);

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
        [features{sample_num, i}] = dtw_minima(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2, 10, 20);
    end
    toc
    songs_checked = [songs_checked;songs_to_check]
end