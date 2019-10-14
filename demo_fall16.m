annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';

out_file = 'D:/Sample Detection/sample_detection/predictions/';

f_id = fopen([out_file,num2str(i),'.csv'],'w');
annotation = csvread(annotation_file);

load features

%% Run this to initialize demo; Train SVM
% genFeatureMat;
% train_data = combine_fmatcells(fmat_in,lab_in);
% svm = fitcsvm(train_data(:,1:7), train_data(:,8));


%%
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

    [feature_vecs_song, ~, start_loc, flag] = get_feature_vecs(features{i}, length_of_sample, time_data, 22050, 1024);

    y = predict(svm, feature_vecs_song);
    predicted_time = start_loc(y == 1)*1024/22050;
    
    for j = 1:numel(predicted_time)
        fprintf(f_id,'%f,point\n',predicted_time(j));
    end
    fclose(f_id);
    soundsc(sample, 22050);
    fprintf('Time Annotations: %s\nSuspect File: %s\nPitch Shift factor: %2.2f\n', time_file, filenum2, annotation(i,5))