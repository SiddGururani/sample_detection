clc;
annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Mat/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Mat/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';

annotation = csvread(annotation_file);

feature_mat_pos = cell(80,1);
load length_of_sample
load features_pos
for i = 1:80
    % Get time annotations
    if(annotation(i,6) < 10)
        time_file = ['0',num2str(annotation(i,6))];
    else
        time_file = num2str(annotation(i,6));
    end
    time_data = importdata([time_dir, time_file, '.csv']);
    for k = 1:numel(time_data)
        time_data{k} = strrep(time_data{k},',New Point','');
    end
    time_data = str2double(time_data);
    [feature_vecs_song, labels_song, start_locs, flag] = get_feature_vecs(features_pos{i}, length_of_sample(i), time_data, 22050, 1024);
    feature_mat_pos{i} = [feature_vecs_song, labels_song, start_locs];
end