a = [8,9,11,15,16,17,18,19,21,22,23,24,26,28,29,30];
annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';
features_dir = './Features/';
annotation = csvread(annotation_file);

feature_mat = [];
% labels = [];skip
% problematic = [];
c = 1;
n = 1;
lab_in = cell(80,20);
fmat_in = cell(80,20);

% features = {};
for i = 1:80
    i
    load(['./Activations/Act_',num2str(i)])
    [features{i}] = extract_dtw_features(acts{i}.sample_H,acts{i}.suspect_H, 'cosine');
% if(annotation(i,1) < 10)
%         filenum1 = ['0',num2str(annotation(i,1))];
%     else
%         filenum1 = num2str(annotation(i,1));
%     end
% 
%     [sample,fs1] = audioread([sample_dir, filenum1,'.mp3']);
%     sample = sample(ceil(fs1*annotation(i,3)):ceil(fs1*annotation(i,4)),:);
% 
%     % Downsample to 22050hz
%     if(fs1 > 22050)
%         sample = downsample(sample,fs1/22050);
%         fs1 = 22050;
%     end
%     X = spectrogram(mean(sample,2), 4096, 4096-1024);
%     length_of_sample = size(X,2);
%     for j = 1:1
% %         if any(i == skipped)
% %             continue
% %         end
%         if j == 1
%             if(annotation(i,6) < 10)
%                 time_file = ['0',num2str(annotation(i,6))];
%             else
%                 time_file = num2str(annotation(i,6));
%             end
%             time_data = importdata([time_dir, time_file, '.csv']);
%             for k = 1:numel(time_data)
%                 time_data{k} = strrep(time_data{k},',New Point','');
%             end
%             time_data = str2double(time_data);
%         else
%             time_data = [];
%         end
% 
%     [feature_vecs_song, labels_song, start_loc, flag] = get_feature_vecs(features{1,j}, length_of_sample, time_data, 22050, 1024);
%     %     if flag ~= 0
%     %         problematic = [problematic, i];
%     %     end
% %         lab_in{i} = labels(c:c+numel(start_loc)-1);
% %         c = c+numel(start_loc);
% 
%     lab_in{i,j} = labels_song;
%     fmat_in{i,j} = feature_vecs_song;
%     %     feature_mat = [feature_mat; feature_vecs_song];
%     %     labels = [labels; labels_song];
%     %     save labels labels;
%     end
end