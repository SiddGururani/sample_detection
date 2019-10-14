function [accs, tp, tn, fp, fn, m_tp, m_fp, m_tn, m_fn] = test_algorithm(model_tree, all_fmat_cell, prob)

annotation_file = 'D:/Academics/7100/Dataset/annotation.csv';
suspect_dir = 'D:/Academics/7100/Dataset/Mat/Copied/';
sample_dir = 'D:/Academics/7100/Dataset/Mat/Originals/';
time_dir = 'D:/Academics/7100/Dataset/Anno/new/';
annotation = csvread(annotation_file);

fp = 0;
fn = 0;
tp = 0;
tn = 0;

m_fp = 0;
m_tp = 0;
m_fn = 0;
m_tn = 0;

tolerance = 1;
for i = 51:80
    for j = 1:10
        fp_ = 0;
        fn_ = 0;
        tp_ = 0;
        tn_ = 0;
        fmat = all_fmat_cell{i,j};
        start_locs = fmat(:,end);
        labels = fmat(:,end-1);
        fmat(:,end-1:end) = [];
        % Remove features
%         fmat(:,2) = [];
        [predictions,scores] = predict(model_tree,fmat);
        predictions = cellfun(@str2double,predictions);
%         samples_detected = find(predictions == 1);
        locations = start_locs*1024/22050;
        probabilities = scores(:,2);
        remove_ind = find(probabilities < prob);
        locations(remove_ind) = [];
        if j == 1
            flag = 0;
            % sample is present in these files so fetch ground truth
            % annotations
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
            
            % Find all 1 predictions
            for k = 1:numel(time_data)
                index = find(abs(locations - time_data(k)) <= tolerance);
                if(numel(index) == 0)
                    fn_ = fn_ + 1;
                elseif(numel(index) == 1)
                    flag = 1;
                    tp_ = tp_ + 1;
                    locations(index) = [];
                else
                    flag = 1;
                    close = locations(index);
                    difference = abs(locations - time_data(k));
                    [~,min_idx] = min(difference);
                    locations(index) = [];
                    tp_ = tp_ + 1;
                end
            end
            if flag == 1
                m_tp = m_tp + 1;
            else
                m_fn = m_fn + 1;
            end
            fp_ = fp_ + numel(locations);
            tn_ = tn_ + numel(predictions) - fp_ - tp_;
        else
            fp = fp+numel(locations);
            tn = tn+numel(predictions)-numel(locations);
            if ~isempty(locations)
                m_fp = m_fp + 1;
            else
                m_tn = m_tn + 1;
            end
        end
        tp = tp + tp_;
        fp = fp + fp_;
        tn = tn + tn_;
        fn = fn + fn_;
    end
end
precision = tp/(tp+fp);
recall = tp/(tp+fn);
f_measure = 2*precision*recall/(precision+recall);
fp_rate = fp/(fp+tn);
fn_rate = fn/(fn+tp);
micro_accs = [precision, recall, f_measure, fp_rate, fn_rate];

m_precision = m_tp/(m_tp+m_fp);
m_recall = m_tp/(m_tp+m_fn);
m_f_measure = 2*m_precision*m_recall/(m_precision+m_recall);
m_fp_rate = m_fp/(m_fp+m_tn);
m_fn_rate = m_fn/(m_fn+m_tp);
macro_accs = [m_precision, m_recall, m_f_measure, m_fp_rate, m_fn_rate];

accs = [micro_accs;macro_accs];
disp(num2str(tp+tn+fp));