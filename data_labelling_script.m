% Script to help label the data
annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';

annotation = csvread(annotation_file);
load new_features.mat
%figure; hold on;
%costs = cell(1,80);
%locs = cell(1,80);
%labels = cell(1,40);
for i = 1:80
   if(annotation(i,2) < 10)
       filenum2 = ['0',num2str(annotation(i,2))];
   else
       filenum2 = num2str(annotation(i,2));
   end
   if(annotation(i,6) < 10)
       time_file = ['0',num2str(annotation(i,6))];
   else
       time_file = num2str(annotation(i,6));
   end
   [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
   a = find(suspect~=0);
   suspect = suspect(a(1):end,:);
%    [~,fs1] = audioread([sample_dir, filenum1,'.mp3'], [1,2]);
%    sample = audioread([sample_dir, filenum1,'.mp3'],[ceil(fs1*annotation(i,3)) ceil(fs1*annotation(i,4))]);
%    a = find(sample~=0);
%    sample = sample(a(1):end,:);
%    [conf, locs{i}, costs{i}] = pitch_and_time(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2);
   time_offset = a(1)/fs2;
   time_data = importdata([time_dir, time_file, '.csv']);
   for j = 1:numel(time_data)
       time_data{j} = strrep(time_data{j},',New Point','');
   end
   time_data = str2double(time_data);
   time_data = time_data - time_offset;

   [~, locs_in_step] = featureExtract(costs{i}, locs{i}, slope_dev{i});
   l = zeros(1, numel(locs_in_step));
   
   locs_in_step(2,:) = locs_in_step(1,:) * 1024/22050;
   
   not_found = [];
   ind = [];
   count1 = 1;
   count2 = 1;
   for j = 1:numel(time_data)
       index = find(abs(locs_in_step(2,:) - time_data(j)) <= 1);
       if(numel(index)==0)
           not_found(count1) = time_data(j);
           count1 = count1+1;
       elseif(numel(index) == 1)
           ind(count2) = index;
           count2 = count2+1;
       else
           c = costs{i}(index);
           [~,min_c] = min(c);
           ind(count2) = index(min_c);
           count2 = count2+1;
       end
   end
   l(ind) = 1;
   
   labels_all{i}=l;
   %fprintf('Sample:%s\tSuspect:%s\t Confidence of sample present:%f\n',filenum1,filenum2,conf);
   %save costs locs
end