% Script to evaluate the classifier
annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';

annotation = csvread(annotation_file);
load new_features
%figure; hold on;
%costs = cell(1,80);
%locs = cell(1,80);
%labels = cell(1,40);
tp = 0;
fp = 0;
fn = 0;
tn = 0;

% generateTrainingMatrix();

% ens = trainEnsemble(Train_feature_mat(:,1:4), Train_labels);
tolerance = 2.5;
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
   
   locations = heuristic_search(costs{i}, locs{i}, slope_dev{i});
   locations_in_time = locations*1024/22050;
   for j = 1:numel(time_data)
       index = find(abs(locations_in_time - time_data(j)) <= tolerance);
       if(numel(index) == 0)
           fn = fn + 1;
       elseif(numel(index) == 1)
           tp = tp + 1;
           locations_in_time(index) = [];
           locations(index) = [];
       else
           close = locations_in_time(index);
           difference = abs(locations_in_time - time_data(j));
           [~,min_idx] = min(difference);
           locations_in_time(min_idx) = [];
           locations(min_idx) = [];
           tp = tp + 1;
       end
   end
   fp = fp + numel(locations_in_time);
end

precision = tp/(tp+fp)
recall = tp/(tp+fn)
f_measure = 2*precision*recall/(precision+recall)