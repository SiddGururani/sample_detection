annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';

annotation = csvread(annotation_file);

%figure; hold on;
dists = cell(1,80);
% costs = cell(1,80);
% locs = cell(1,80);
% slope_dev = cell(1,80);
features = cell(1,80);
tic
for i = 1:80
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
    [suspect, fs2] = audioread([suspect_dir, filenum2,'.mp3']);
    [sample,fs1] = audioread([sample_dir, filenum1,'.mp3']);
    sample = sample(ceil(fs1*annotation(i,3)):ceil(fs1*annotation(i,4)),:);
    
    % Downsample to 22050hz
    if(fs1 > 22050)
        sample = downsample(sample,fs1/22050);
        fs1 = 22050;
    end
    if(fs2 > 22050)
        suspect = downsample(suspect,fs2/22050);
        fs2 = 22050;
    end
    
    % Remove leading 0s
%     a = find(suspect(:,1)~=0);
%     suspect = suspect(a(1):end,:);
%     b = find(sample~=0);
%     sample = sample(b(1):end,:);

    % Get time instants for sample
    time_offset = 0;
    time_data = importdata([time_dir, time_file, '.csv']);
    for j = 1:numel(time_data)
       time_data{j} = strrep(time_data{j},',New Point','');
    end
    time_data = str2double(time_data);
    time_data = time_data - time_offset;
%    [slope_dev{i}, locs{i}, costs{i}] = pitch_and_time(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2);
%    [~, ~, ~,dists{i}] = pitch_and_time(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2);
    [features{i}, D, H] = dtw_minima(sample, suspect,annotation(i,1), annotation(i,2), annotation(i,5), fs1, fs2, 10, 20, time_data);
%     time_offset = a(1)/fs2;
%     locs = time_data*22050/1024;

%     x = 1:numel(features{i}.costs);
%     x = x*1024/22050;
%     figure;
%     plot(x, features{i}.costs);
%     hold on;
%     y1 = get(gca, 'ylim');
%     for j = 1:numel(time_data)
%        plot([time_data(j) time_data(j)], y1);
%     end
%     hold off;
%     
    figure;
    x = [1:numel(D(1,:))]*1024/22050;
    y = [1:numel(D(:,1))]*1024/22050;
    imagesc(x,y,D);
    hold on;
    y1 = get(gca, 'ylim');
    for j = 1:numel(time_data)
       plot([time_data(j) time_data(j)], y1, 'red');
    end
    hold off;
    
%     figure;
%     hold on
%     [n,y] = size(H);
%     x = [1:y]*1024/22050;
% %     for j = 1:n
% %         plot(x,H(j,:));
% %     end
%     plot(x,H(1,:));
%     y1 = get(gca, 'ylim');
%     for j = 1:numel(time_data)
%        plot([time_data(j) time_data(j)], y1, 'red');
%     end
%     hold off;



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
