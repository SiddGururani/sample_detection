annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';
annotation = csvread(annotation_file);

load features

feature_mat = [];
% labels = [];
% problematic = [];
c = 1;
n = 1;
lab_in = cell(1,40);
fmat_in = cell(1,40);

for i = 1:40

    if any(i == skipped)
        continue
    end
    i
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
    if(annotation(i,6) < 10)
        time_file = ['0',num2str(annotation(i,6))];
    else
        time_file = num2str(annotation(i,6));
    end
    
    [sample,fs1] = audioread([sample_dir, filenum1,'.mp3']);
    sample = sample(ceil(fs1*annotation(i,3)):ceil(fs1*annotation(i,4)),:);
    
    % Downsample to 22050hz
    if(fs1 > 22050)
        sample = downsample(sample,fs1/22050);
        fs1 = 22050;
    end
    X = spectrogram(mean(sample,2), 4096, 4096-1024);
    length_of_sample = size(X,2);
    
    time_data = importdata([time_dir, time_file, '.csv']);
    for j = 1:numel(time_data)
        time_data{j} = strrep(time_data{j},',New Point','');
    end
    time_data = str2double(time_data);

    [feature_vecs_song, labels_song, start_loc, flag] = get_feature_vecs(features{i}, length_of_sample, time_data, 22050, 1024);
%     if flag ~= 0
%         problematic = [problematic, i];
%     end
    lab_in{i} = labels(c:c+numel(start_loc)-1);
    c = c+numel(start_loc);
    fmat_in{i} = feature_vecs_song;
%     feature_mat = [feature_mat; feature_vecs_song];
%     labels = [labels; labels_song];
%     save labels labels;
end