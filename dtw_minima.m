function [ features ] = dtw_minima( data_orig, data_copy, sample_no, suspect_no, pitch_shift, fs1, fs2, low_rank_sample, low_rank_mix, time_data )
%DTW_MINIMA Summary of this function goes here
%   Detailed explanation goes here
tic


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
k = min(low_rank_sample, min(size(Xo))); 
[Bo, Ho, r] = nnmf(abs(Xo), k);

% Normalize the templates by RMS and scale activations accordingly
Bo_norm = sqrt(sum(Bo.^2,1)./size(Bo,1));
Bo = bsxfun(@times, Bo, 1./Bo_norm);
Ho = bsxfun(@times, Ho, Bo_norm');
% Check for low-rank < k
rank_check = sum(Ho,2);
if ~isempty(find(rank_check == 0))
    Ho(find(rank_check == 0),:) = [];
    Bo(:,find(rank_check == 0)) = [];
    k = k - numel(find(rank_check == 0));
end

%% Computing pitch shifted templates for detecting pitch shifted samples

N = numel(Bo(:,1));
Bo_concat = Bo;

% n : number of quarter-tone shifts, 10 up, 10 down and no shift.
n = 21; 
for i=1:10 %shift up
    t1 = 1:N;
    t2 = (t1)/(2^(i*0.5/12));
    B_shift = interp1(t1, Bo, t2,'spline');
    if t1(end)<t2(end)
        B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
    end
    % Normalize shifted templates
    b_norm = sqrt(sum(B_shift.^2,1)./size(B_shift,1));
    B_shift = bsxfun(@times, B_shift, 1./b_norm);
    Bo_concat = [Bo_concat B_shift];
end

for i=1:10 %shift down
    t1 = 1:N;
    t2 = (t1)/(2^(-i*0.5/12));
    B_shift = interp1(t1, Bo, t2,'spline');
    if t1(end)<t2(end)
        B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
    end
    % Normalize shifted templates
    b_norm = sqrt(sum(B_shift.^2,1)./size(B_shift,1));
    B_shift = bsxfun(@times, B_shift, 1./b_norm);
    Bo_concat = [Bo_concat B_shift];
end

clear B_shift Bo

%Known pitch-shift factor for evaluation purposes
% N = numel(Bo(:,1));
% t1 = 1:N;
% t2 = (t1)/(2^(pitch_shift/12));
% B_shift = interp1(t1, Bo, t2,'pchip');
% if t1(end)<t2(end)
%     B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = min(B_shift(B_shift>0));
% end
% 
% b_norm = sqrt(sum(B_shift.^2,1)./size(B_shift,1));
% B_shift = bsxfun(@times, B_shift, 1./b_norm);
% clear Bo
%% Performing partially fixed NMF using the precomputed template matrix    

% [~, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), B_shift, [], [], [], low_rank_mix, 0);

%% Performing partially fixed NMF using the pitch-shift templates concatenated as well. 
%  use either one of the PFNMF sections

[~, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), Bo_concat, [], [], [], low_rank_mix, 0);

%% Normalize the two activation matrices before computing correlation
% DO NOT RUN

% L1 norm
% for i = 1:k
%     Ho(i,:) = Ho(i,:)/norm(Ho(i,:),1);
% end
% 
% for i = 1:(n+1)*k
%     Ho_hypo(i,:) = Ho_hypo(i,:)/norm(Ho_hypo(i,:),1);
% end

% Norm by max

Ho = Ho./max(Ho(:));
Ho_hypo = Ho_hypo./max(Ho_hypo(:));

% OR normalize each set of activations for different pitch shift factors
% separately
Ho = Ho./max(Ho(:));
for shift = 1:n
    H_shift = Ho_hypo((shift-1)*k+1:shift*k,:);
    H_shift = H_shift./max(H_shift(:));
    Ho_hypo((shift-1)*k+1:shift*k,:) = H_shift;
end


%% time stretch detection
% tic;

c = cell(n, 1);
a = cell(n, 1);
min_idx = 0;
all_min_cost = Inf;
% Run DTW for all pitch shifts. find the shift which results in lowest
% cost for all paths.
for shift = 1:n
    Ho_shift = Ho_hypo((shift-1)*k+1:shift*k,:);
%     D = pdist2(Ho', Ho_shift','euclidean');
%     D = myDistMat(Ho', Ho_shift');
    D = pdist2(Ho', Ho_shift','euclidean');
    %MATLAB DTW call
    [a{shift},c{shift}] = DTW_multipath(D);
    for i = 1:numel(a{shift})
        path = a{shift}{i};
        c_shift = c{shift};
        cost(i) = c_shift(path(end,1), path(end, 2));
    end
    min_cost = min(cost);
    if min_cost < all_min_cost
        min_idx = shift;
        all_min_cost = min_cost;
        
    end
end

a = a{min_idx};
c = c{min_idx};

features = struct();
features.costs = zeros(numel(a),1);
features.start_loc = zeros(numel(a),1);
features.path_length = zeros(numel(a),1);
features.path_slope = zeros(numel(a),1);
features.slope_dev = zeros(numel(a),1);

for i = 1:numel(a)
    path = a{i};
    features.start_loc(i) = path(1,2);
    features.path_length(i) = size(path,1);
    
    % Not normalizing. Get raw value now. Normalize later.
    features.costs(i) = c(path(end,1), path(end, 2)); %/features.path_length(i);
    [features.slope_dev(i), features.path_slope(i)] = slope_deviation(path); %/features.path_length(i);
end

% temp = features.costs*-1;
% [~,locs_cost_minima]= findpeaks(temp);
% 
% temp = features.slope_dev*-1;
% [~,locs_slope_dev] = findpeaks(temp);
% 
% locations = start_loc;
% av_slope = (a(end,2) - a(1,2))/(a(end,1) - a(1,1));
% cum_dev = sum(abs(a(2:end-1,2) - a(2:end-1,1)*av_slope)/sqrt(1+av_slope*av_slope)); 
% cum_dev = cum_dev/(size(a,1)-2);
% [costs_m(i), locs_m(i)] = min(c(end,:));
% locs_m(i) = locs_m(i) + i;
% costs_m(i) = costs_m(i)/size(a,1);
% slope_dev(i) = cum_dev;

toc;


%% Strech/compress activations based on time stretch factor.

% fn = c(end,:);
% [~, gl_min_ind] = min(fn);
% min_path = a{gl_min_ind};
% slope = (min_path(end,2) - min_path(1,2))/(min_path(end,1) - min_path(1,1))
% 
% N = size(Ho,2);
% t1 = 1:N;
% Ho_strech = interp1(t1, Ho', linspace(1, N, N*slope),'spline')';
end

