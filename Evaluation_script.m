suspect_dir = '../Audio/Suspect/';
sample_dir = '../Audio/Sample/';

annotations = dir([sample_dir '*.txt']);
file_suspect = dir([suspect_dir '*.mp3']);
file_sample = dir([sample_dir '*.wav']);

detect_tp = 0;
detect_tn = 0;
detect_fp = 0;
detect_fn = 0;
for i = 1:numel(file_sample)
    for j = 1:numel(file_suspect)
        sample = [sample_dir file_sample(i).name];
        suspect = [suspect_dir file_suspect(j).name];
        [result, locations] = Experiment_NMF(sample, suspect);
        truth_file = [sample_dir annotations(i).name]
        true_locs = dlmread(truth_file,'\t',1,0);
        fid = fopen(file);
        true_file = fgetl(fid);
        
        %% Evaluation starts here. Currently only detection is evaluated. Add 
        %   code for evaluating locations as well.
        if strcmp(file_suspect(j).name,true_file) == 1
            if result == 1
                detect_tp = detect_tp+1;
            else
                detect_fn = detect_fn+1;
            end
        else
            if result == 1
                detect_fp = detect_fp+1;
            else
                detect_tn = detect_tn+1;
            end
        end
    end
end

detect_P = detect_tp/(detect_tp+detect_fp);
detect_R = detect_tp/(detect_tp+detect_fn);
detect_f = 2*detect_P*detect_R/(detect_P+detect_R);