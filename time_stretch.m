function [result, locs, costs, min_in_step] = time_stretch(sample, suspect, sample_no, suspect_no)
[data_orig,fs] = audioread(sample);
[data_copy,fs] = audioread(suspect);
% data_orig = bsxfun(@rdivide, data_orig, rms(data_orig,1));
% data_copy = bsxfun(@rdivide, data_copy, rms(data_copy,1));
data_orig = downsample(data_orig,2);
data_copy = downsample(data_copy,2);
fs = fs/2;

%% Computing the STFT spectrograms
data_orig = mean(data_orig,2);
data_copy = mean(data_copy,2);

window = 4096;
hop = 1024;
[Xo, freq, time] = spectrogram(data_orig, window, window-hop);
Xs = spectrogram(data_copy, window, window-hop);

clear data_orig data_copy
f = 0:(length(freq)-1);
f = f*((fs/2)/length(freq));

midi = 69 + 12*log2(f/440);

%% Performing Non-negative Matrix Factorization on the original sample spectrogram

n = 0; % no pitch shifts
k = 10; 
[Bo, Ho, r] = nnmf(abs(Xo), k);

% Check for low-rank < k
rank_check = sum(Ho,2);
if ~isempty(find(rank_check == 0))
    Ho(find(rank_check == 0),:) = [];
    Bo(:,find(rank_check == 0)) = [];
    k = k - numel(find(rank_check == 0));
end

%% Computing pitch shifted templates for detecting pitch shifted samples

% N = numel(Bo(:,1));
% Bo_concat = Bo;
% 
% % n : number of semi-tone shifts.
% n = 12; 
% for i=1:12
%     t1 = 1:N;
%     t2 = (t1)/(2^(-i/12));
%     B_shift = interp1(t1, Bo, t2,'spline');
% %     if t1(end)<t2(end)
% %         B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
% %     end
%     Bo_concat = [Bo_concat B_shift];
% end
% 
% clear B_shift Bo

%% Performing partially fixed NMF using the precomputed template matrix    

[Bo1, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), Bo, [], [], [], 20, 0);


%% Performing partially fixed NMF using the pitch-shift templates concatenated as well. 
%  use either one of the PFNMF sections

% [~, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), Bo_concat, [], [], [], 0, 0);

%% Normalize the two activation matrices before computing correlation
% DO NOT RUN

for i = 1:k
    Ho(i,:) = Ho(i,:)/norm(Ho(i,:),1);
end

for i = 1:(n+1)*k
    Ho_hypo(i,:) = Ho_hypo(i,:)/norm(Ho_hypo(i,:),1);
end

%% time stretch detection
% tic;
D = pdist2(Ho', Ho_hypo','correlation');
costs = zeros(1,size(Ho_hypo,2)- floor(size(Ho,2)/4));
locs = zeros(1,size(Ho_hypo,2) - floor(size(Ho,2)/4));
% new_costs = zeros(1,size(Ho_hypo,2) - floor(size(Ho,2)/4));
costs_m = zeros(1,size(Ho_hypo,2)- floor(size(Ho,2)/4));
locs_m = zeros(1,size(Ho_hypo,2) - floor(size(Ho,2)/4));

% p = cell(size(Ho_hypo,2),1);
%MATLAB DTW call
tic
% for i=1:(size(Ho_hypo,2) - floor(size(Ho,2)/4));
% 	[a,c] = DTW(D(:,i:end));
% %     p{i} = a;
% 	[costs_m(i), locs_m(i)] = min(c(end,:));
%     locs_m(i) = locs_m(i) + i;
%     costs_m(i) = costs_m(i)/size(a,1);
% end
% toc;

%C++ DTW call
distfile = 'C:/Users/SiddGururani/Desktop/MUSIC-8903-2016-exercise3_dtw/bin/release/distmat.bin';
outfile = 'C:/Users/SiddGururani/Desktop/MUSIC-8903-2016-exercise3_dtw/bin/release/output.bin';
executable = 'C:/Users/SiddGururani/Desktop/MUSIC-8903-2016-exercise3_dtw/bin/release/MUSI8903Exec.exe';
tic
fid = fopen(distfile, 'w');
% Row-wise writing instead of column-wise writing
fwrite(fid,D','float');
fclose(fid);
for i=1:(size(Ho_hypo,2) - floor(size(Ho,2)/4))
    system([executable ' ' num2str(size(D,1)) ' ' num2str(size(D,2)) ' ' num2str(i-1) ' ' distfile ' ' outfile ' 1>NUL 2>NUL']);
    fid = fopen(outfile,'r');
    dtw_out = fread(fid, [3 1], 'float');
    fclose(fid);
    locs(i) = dtw_out(3) + i + 1;
    costs(i) = dtw_out(2)/dtw_out(1);
    [a,c] = DTW(D(:,i:end));
%     p{i} = a;
	[costs_m(i), locs_m(i)] = min(c(end,:));
    locs_m(i) = locs_m(i) + i;
    costs_m(i) = costs_m(i)/size(a,1);
end
toc;
% For testing purposes
% filename = ['test_', num2str(sample_no), '_', num2str(suspect_no),'.mat'];
% save(filename,'locs', 'costs');
% result = 1;
% locs = 1;
% load(filename);






% code for including the step length for cost computation
locs_diff = diff(locs);
locs_diff = [1 locs_diff];
steps = find(locs_diff~=0);
steps = [steps, numel(locs)];
length_steps = diff(steps);
length_steps(end) = length_steps(end)+1;%to compensate for last step
for i = 1:numel(costs)
    for j = 2:numel(steps)
        if(i < steps(j) && i >= steps(j-1))
            new_costs(i) = costs(i)/length_steps(j-1);
        end
    end
end
new_costs(numel(costs)) = costs(end)/length_steps(end);

% Get minimum cost within each step
min_in_step = zeros(1, numel(steps));
locs_in_step = zeros(1, numel(steps));
for i = 1:numel(steps)-1
    [min_in_step(i), locs_in_step(i)] = min(costs(steps(i):steps(i+1)));
    locs_in_step(i) = locs_in_step(i) + steps(i);
end
min_in_step(end) = min(costs(steps(end):end));
locs_in_step(end) = locs_in_step(end) + steps(end);

mean_cost = mean(costs);
stdev = std(costs);

% Removing candidates whose value is greater than the mean cost
locs_in_step((min_in_step-mean_cost)>0) = [];
min_in_step((min_in_step-mean_cost)>0) = [];

% Removing candidates whose value isn't lower than 1.5 times the standard
% deviation of the costs.
locs_in_step((abs(min_in_step-mean_cost)-3*stdev)<0) = [];
min_in_step((abs(min_in_step-mean_cost)-3*stdev)<0) = [];

if(isempty(locs_in_step))
    result = 0;
else
    result = 1;
end

% figure; plot(costs);title(['costs for sample# ',num2str(sample_no),' and suspect# ',num2str(suspect_no)]);
% figure; plot(locs);title(['locations for sample# ',num2str(sample_no),' and suspect# ',num2str(suspect_no)]);
% figure; plot(new_costs);title(['normalized costs/length for sample# ',num2str(sample_no),' and suspect# ',num2str(suspect_no)]);
locs = locs_in_step;
end