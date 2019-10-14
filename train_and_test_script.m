clc;
annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Mat/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Mat/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';
annotation = csvread(annotation_file);
% Load below for first experiment
% load features_final

% Load below for second experiment
% load features_pos_remove_extra_candidates.mat
% load features_final feature_mat_neg

% Load below for third experiment
load features_13Dim.mat

all_fmat_cell = [feature_mat_pos,feature_mat_neg];
clear feature_mat_pos feature_mat_neg

% Train TreeBagger class with first 50 samples
training_data = [];
% problematic = [9,11,12,16,17];
problematic = [];
for i = 1:50
    if isempty(find(problematic == i))
        for j = 1:10
            training_data = [training_data;all_fmat_cell{i,j}];
        end
    end
end

% Terribly skewed data
numel(find(training_data(:,end-1)==0))
numel(find(training_data(:,end-1)==1))

% Sample from negative classes to balance the classes
% balanced_training_data = balance_data(training_data,1);
% start_locs = balanced_training_data(:,end);
% balanced_training_data(:,end) = [];
% training_data = balanced_training_data;

% Unbalanced
training_data(:,end) = [];

% Remove features
% training_data(:,2) = [];
model_tree = TreeBagger(200,training_data(:,1:end-1),training_data(:,end),'OOBPrediction','on');

% Test on remaining data
p = linspace(0,1,100);
acc = [];
for i = 1:numel(p)
    [acc_, tp, tn, fp, fn, m_tp, m_fp, m_tn, m_fn] = test_algorithm(model_tree, all_fmat_cell, p(i));
    acc = [acc; acc_];
end

% tolerance = 1;
% for i = 51:80
%     for j = 1:10
%         fmat = all_fmat_cell{i,j};
%         start_locs = fmat(:,end);
%         labels = fmat(:,end-1);
%         fmat(:,end-1:end) = [];
%         % Remove features
% %         fmat(:,2) = [];
%         [predictions,scores] = predict(model_tree,fmat);
%         predictions = cellfun(@str2double,predictions);
%         samples_detected = find(predictions == 1);
%         locations = start_locs(samples_detected)*1024/22050;
%         probabilities = scores(samples_detected,2);
%         remove_ind = find(probabilities < 0.5);
%         locations(remove_ind) = [];
%         if j == 1
%             flag = 0;
%             % sample is present in these files so fetch ground truth
%             % annotations
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
%             
%             % Find all 1 predictions
%             for k = 1:numel(time_data)
%                 index = find(abs(locations - time_data(k)) <= tolerance);
%                 if(numel(index) == 0)
%                     fn = fn + 1;
%                 elseif(numel(index) == 1)
%                     flag = 1;
%                     tp = tp + 1;
%                     locations(index) = [];
%                 else
%                     flag = 1;
%                     close = locations(index);
%                     difference = abs(locations - time_data(k));
%                     [~,min_idx] = min(difference);
%                     locations(min_idx) = [];
%                     tp = tp + 1;
%                 end
%             end
%             if flag == 1
%                 m_tp = m_tp + 1;
%             else
%                 m_fn = m_fn + 1;
%             end
%             fp = fp + numel(locations);
%             tn = tn + numel(predictions) - fp - tp;
%         else
%             fp = fp+numel(locations);
%             tn = tn+numel(predictions)-numel(locations);
%             if ~isempty(locations)
%                 m_fp = m_fp + 1;
%             else
%                 m_tn = m_tn + 1;
%             end
%         end
%     end
% end
% precision = tp/(tp+fp);
% recall = tp/(tp+fn);
% f_measure = 2*precision*recall/(precision+recall);
% fp_rate = fp/(fp+tn);
% fn_rate = fn/(fn+tp);
% micro_accs = [precision, recall, f_measure, fp_rate, fn_rate];
% 
% m_precision = m_tp/(m_tp+m_fp);
% m_recall = m_tp/(m_tp+m_fn);
% m_f_measure = 2*m_precision*m_recall/(m_precision+m_recall);
% m_fp_rate = m_fp/(m_fp+m_tn);
% m_fn_rate = m_fn/(m_fn+m_tp);
% macro_accs = [m_precision, m_recall, m_f_measure, m_fp_rate, m_fn_rate];
% 
% accs = [micro_accs;macro_accs]
