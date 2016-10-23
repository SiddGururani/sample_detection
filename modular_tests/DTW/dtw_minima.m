function [ locations ] = dtw_minima( data_orig, data_copy, sample_no, suspect_no, pitch_shift, fs1, fs2 )
%DTW_MINIMA Summary of this function goes here
%   Detailed explanation goes here
tic
if(fs1 > 22050)
    data_orig = downsample(data_orig,fs1/22050);
    fs1 = 22050;
end
if(fs2 > 22050)
    data_copy = downsample(data_copy,fs2/22050);
    fs2 = 22050;
end

%% Computing the STFT spectrograms
data_orig = mean(data_orig,2);
data_copy = mean(data_copy,2);

window = 4096; % Play around with this
hop = 1024;
[Xo, freq, time] = spectrogram(data_orig, window, window-hop);
Xs = spectrogram(data_copy, window, window-hop);

clear data_orig data_copy

%% Performing Non-negative Matrix Factorization on the original sample spectrogram

n = 0; % no pitch shifts
k = min(10, min(size(Xo))); 
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

%Known pitch-shift factor for evaluation purposes
N = numel(Bo(:,1));
t1 = 1:N;
t2 = (t1)/(2^(pitch_shift/12));
B_shift = interp1(t1, Bo, t2,'spline');
if t1(end)<t2(end)
    B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = min(B_shift(B_shift>0));
end
% clear Bo
%% Performing partially fixed NMF using the precomputed template matrix    

[~, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), B_shift, [], [], [], 20, 0);


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

% for i = 1:k
%     Ho(i,:) = (Ho(i,:) - min(Ho(i,:)))/(max(Ho(i,:)) - min(Ho(i,:)));
% end
% 
% for i = 1:(n+1)*k
%     Ho_hypo(i,:) = (Ho_hypo(i,:) - min(Ho_hypo(i,:)))/(max(Ho_hypo(i,:)) - min(Ho_hypo(i,:)));
% end

%% time stretch detection
% tic;
D = pdist2(Ho', Ho_hypo','correlation');
% costs = zeros(1,size(Ho_hypo,2)- floor(size(Ho,2)/4));
% locs = zeros(1,size(Ho_hypo,2) - floor(size(Ho,2)/4));
% slope_dev = zeros(1, size(Ho_hypo,2) - floor(size(Ho,2)/4));
% new_costs = zeros(1,size(Ho_hypo,2) - floor(size(Ho,2)/4));
% costs_m = zeros(1,size(Ho_hypo,2)- floor(size(Ho,2)/4));
% locs_m = zeros(1,size(Ho_hypo,2) - floor(size(Ho,2)/4));

% Reduce the number of start points to look at

% for i=1:(size(Ho_hypo,2) - floor(size(Ho,2)/4))
%     [p,c] = DTW(D(1:min([10, size(Ho,2)]
% end

%MATLAB DTW call

[a,c] = DTW_multipath(D);

costs = zeros(numel(a));
start_loc = zeros(numel(a));
path_length = zeros(numel(a));
slope_dev = zeros(numel(a));
for i = 1:numel(a)
    path = a{i};
    start_loc(i) = path(1,2);
    costs(i) = c(path(end,1), path(end, 2));
    path_length(i) = size(path,1);
    slope_dev(i) = slope_deviation(path);
end

% av_slope = (a(end,2) - a(1,2))/(a(end,1) - a(1,1));
% cum_dev = sum(abs(a(2:end-1,2) - a(2:end-1,1)*av_slope)/sqrt(1+av_slope*av_slope)); 
% cum_dev = cum_dev/(size(a,1)-2);
% [costs_m(i), locs_m(i)] = min(c(end,:));
% locs_m(i) = locs_m(i) + i;
% costs_m(i) = costs_m(i)/size(a,1);
% slope_dev(i) = cum_dev;

toc;

end

