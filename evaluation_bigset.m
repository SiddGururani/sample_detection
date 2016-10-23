annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';

annotation = csvread(annotation_file);

%figure; hold on;
dists = cell(1,80);
% costs = cell(1,80);
% locs = cell(1,80);
% slope_dev = cell(1,80);
tic
for i = 1:80
   if(annotation(i,2) < 10)
       filenum2 = ['0',num2str(annotation(i,2))];
   else
       filenum2 = num2str(annotation(i,2));
   end
   if(annotation(i,1) < 10)
       filenum1 = ['0',num2str(annotation(i,1))];
   else
       filenum1 = num2str(annotation(i,1));
   end
   [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
   a = find(suspect~=0);
   suspect = suspect(a(1):end,:);
   [~,fs1] = audioread([sample_dir, filenum1,'.mp3'], [1,2]);
   sample = audioread([sample_dir, filenum1,'.mp3'],[ceil(fs1*annotation(i,3)) ceil(fs1*annotation(i,4))]);
   a = find(sample~=0);
   sample = sample(a(1):end,:);
%    [slope_dev{i}, locs{i}, costs{i}] = pitch_and_time(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2);
   [~, ~, ~,dists{i}] = pitch_and_time(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2);
   %plot(costs);
   %fprintf('Sample:%s\tSuspect:%s\t Confidence of sample present:%f\n',filenum1,filenum2,conf);
   %save costs locs
end
toc;
% for i = 1:10
%    if(annotation(i,2) < 10)
%        filenum2 = ['0',num2str(annotation(i,2)+1)];
%    else
%        filenum2 = num2str(annotation(i,2)+1);
%    end
%    if(annotation(i,1) < 10)
%        filenum1 = ['0',num2str(annotation(i,1))];
%    else
%        filenum1 = num2str(annotation(i,1));
%    end
%    [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
%    a = find(suspect~=0);
%    suspect = suspect(a(1):end,:);
%    [~,fs1] = audioread([sample_dir, filenum1,'.mp3'], [1,2]);
%    sample = audioread([sample_dir, filenum1,'.mp3'],[ceil(fs1*annotation(i,3)) ceil(fs1*annotation(i,4))]);
%    a = find(sample~=0);
%    sample = sample(a(1):end,:);
%    [slope_dev_wrong{i}, locs_wrong{i}, costs_wrong{i}] = pitch_and_time(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2);
%    
% end
