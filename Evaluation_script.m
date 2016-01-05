% suspect_dir = '../Audio/Suspect/';
% sample_dir = '../Audio/Sample/';

suspect_dir = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/';
sample_dir = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/';

annotations = dir([sample_dir '*.txt']);
% file_suspect = dir([suspect_dir '*.mp3']);
file_suspect = dir([suspect_dir '*.wav']);
file_sample = dir([sample_dir '*.wav']);

detect_tp = 0;
detect_tn = 0;
detect_fp = 0;
detect_fn = 0;
tic
for i = 1:numel(file_sample)
%     detect_fp = 0;
    av_fp = 0;
    av_tp = 0;
    for j = 1:numel(file_suspect)
        sample = [sample_dir file_sample(i).name];
        suspect = [suspect_dir file_suspect(j).name];
%         [result, locations] = Experiment_NMF(sample, suspect);
        result = pitch_shift_exp(sample, suspect);
        truth_file = [sample_dir annotations(i).name];
        fprintf('Sample:%d\tSuspect:%d\tResult:%d\n',i,j,result);
%         true_locs = dlmread(truth_file,'\t',1,0);
%% Evaluation starts here. Currently only detection is evaluated. Add 
%   code for evaluating locations as well.
        fid = fopen(truth_file);
        tline = fgetl(fid);
        while ischar(tline)
            true_file = tline;
            tline = fgetl(fid);
            if strcmp(file_suspect(j).name,true_file) == 1
                if result == 1
                    detect_tp = detect_tp+1;
                    av_tp = av_tp+1;
                else
                    detect_fn = detect_fn+1;
                end
            else
                if result == 1
                    detect_fp = detect_fp+1;
                    av_fp = av_fp+1;
                else
                    detect_tn = detect_tn+1;
                end
            end
        end
        fclose(fid);
    end
    p(i) = av_tp/(av_tp+av_fp);
end
toc
detect_Precision = detect_tp/(detect_tp+detect_fp)
detect_Recall = detect_tp/(detect_tp+detect_fn)
detect_f = 2*detect_Precision*detect_Recall/(detect_Precision+detect_Recall)