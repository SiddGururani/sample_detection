function [features] = extract_dtw_features(Ho, Ho_hypo, distance_metric)

k = size(Ho,1); % Rank
n = size(Ho_hypo,1)/k; % Number of pitch_shifts

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
    D = pdist2(Ho', Ho_shift',distance_metric);
    
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