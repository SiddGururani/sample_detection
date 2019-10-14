clc;
annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Mat/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Mat/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';

annotation = csvread(annotation_file);

feature_mat_neg = cell(80,9);
load length_of_sample
load features_neg
for i = 1:80
    for j = 1:9
        [feature_vecs_song, labels_song, start_locs, flag] = get_feature_vecs(features_neg{i,j}, length_of_sample(i), [], 22050, 1024);
        feature_mat_neg{i,j} = [feature_vecs_song, labels_song, start_locs];
    end
end