annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';
suspect_mat_dir = 'D:/Academics/7100/Dataset/Mat/Copied/';
sample_mat_dir = 'D:/Academics/7100/Dataset/Mat/Originals/';

annotation = csvread(annotation_file);

% dists = cell(1,80);
features = cell(80,20);
activation_pairs = cell(80,20);
songs_checked = [];
for sample_num = 1:80
    sample_num
tic;
if(annotation(sample_num,1) < 10)
   filenum1 = ['0',num2str(annotation(sample_num,1))];
else
   filenum1 = num2str(annotation(sample_num,1));
end
[sample,fs1] = audioread([sample_dir, filenum1,'.mp3']);
save([sample_mat_dir,filenum1,'.mat'],'sample','fs1');

if(annotation(sample_num,2) < 10)
   filenum2 = ['0',num2str(annotation(sample_num,2))];
else
   filenum2 = num2str(annotation(sample_num,2));
end
[suspect,fs2] = audioread([suspect_dir, filenum2,'.mp3']);
save([suspect_mat_dir,filenum2,'.mat'],'suspect','fs2');

end
