function [feature_vecs, label, start_loc, flag] = get_feature_vecs(raw_features, length_of_sample, time_stamps, fs, hop)

all_locs = raw_features.start_loc;
unique_locs = unique(all_locs);

flag = 0;
locs_diff = diff([0; all_locs]);
% locs_diff = [1 locs_diff];
steps = find(locs_diff~=0);
steps = [steps; numel(all_locs)];
length_steps = diff(steps);
length_steps(end) = length_steps(end)+1;

%remove steps shorter than 5 hops
% rem_idx = find(length_steps < 5);
% length_steps(rem_idx) = [];
% unique_locs(rem_idx) = [];

% Normalize length of steps
% length_steps = length_steps./length_of_sample;

label = zeros(numel(unique_locs),1);
cost = zeros(numel(unique_locs),1);
slope_dev = zeros(numel(unique_locs),1);
path_length = zeros(numel(unique_locs),1);
path_slope = zeros(numel(unique_locs),1);
local_cost_mean = zeros(numel(unique_locs),1);
local_cost_std = zeros(numel(unique_locs),1);
local_path_sl_mean = zeros(numel(unique_locs),1);
local_path_sl_std = zeros(numel(unique_locs),1);
local_path_len_mean = zeros(numel(unique_locs),1);
local_path_len_std = zeros(numel(unique_locs),1);
locs_min_cost_all = zeros(numel(unique_locs),1);
local_sl_dev_mean = zeros(numel(unique_locs),1);
local_sl_dev_std = zeros(numel(unique_locs),1);

% Add more features inside this loop
for i = 1:numel(unique_locs)
    local_costs = raw_features.costs(steps(i):steps(i+1));
    local_slope_dev = raw_features.slope_dev(steps(i):steps(i+1));
    local_path_length = raw_features.path_length(steps(i):steps(i+1));
    local_path_slope = raw_features.path_slope(steps(i):steps(i+1));
    local_costs = local_costs./local_path_length;
    local_cost_mean(i) = mean(local_costs);
    local_cost_std(i) = std(local_costs);
    local_path_sl_mean(i) = mean(local_path_slope);
    local_path_sl_std(i) = std(local_path_slope);
    local_path_len_mean(i) = mean(local_path_length);
    local_path_len_std(i) = std(local_path_length);
    
    % New features!!!!!!!!
    local_sl_dev_mean(i) = mean(local_slope_dev);
    local_sl_dev_std(i) = std(local_slope_dev);
    % New features end!!!!!!
    [cost(i),index] = min(local_costs);
    % Normalize step length by path length of min cost path
%     length_steps(i) = length_steps(i)/local_path_length(index);
    % Normalize step length by length of sample
    length_steps(i) = length_steps(i)/length_of_sample;
    path_length(i) = local_path_length(index)./length_of_sample;
    locs_min_cost_all(i) = steps(i)+index;
    slope_dev(i) = local_slope_dev(index);
    path_slope(i) = local_path_slope(index);
    
end

idx_to_remove = [];
for i = 1:numel(time_stamps)
    diff_loc = abs(unique_locs - time_stamps(i)*fs/hop);
    % check that the location is further away than 10 hops or approx 1
    % seconds
    if min(diff_loc) > 10
        flag = 1;
    end
    % check for multiple locations within 20 hops, 
    if numel(find(diff_loc <= 15)) > 1
        % assign the step with lowest cost
        candidates = find(diff_loc <= 15);
        [~, idx] = min(cost(candidates));
        locs_min_cost_t(i) = locs_min_cost_all(candidates(idx));
        label(candidates(idx)) = 1;
        
        % assign step with longest step size
%         candidates = find(diff_loc <= 15);
%         [~, idx] = max(length_steps(candidates));
%         locs_min_cost_t(i) = locs_min_cost_all(candidates(idx));
%         label(candidates(idx)) = 1;

        % Remove other candidates from training set
        candidates(idx) = [];
        idx_to_remove = [idx_to_remove; candidates];
    else
        [~,loc] = min(diff_loc);
        locs_min_cost_t(i) = locs_min_cost_all(loc);
        label(loc) = 1;
    end
end
% 
% figure;
% plot([1:numel(raw_features.costs)]*1024/fs,raw_features.costs./raw_features.path_length);
% hold on;
% y1 = get(gca, 'ylim');
% for j = 1:numel(locs_min_cost_t)
%    plot([time_stamps(j) time_stamps(j)], y1);
% end
% hold off;

cost(idx_to_remove) = [];
slope_dev(idx_to_remove) = [];
path_length(idx_to_remove) = [];
path_slope(idx_to_remove) = [];
length_steps(idx_to_remove) = [];
local_cost_mean(idx_to_remove) = [];
local_cost_std(idx_to_remove) = [];
local_path_sl_mean(idx_to_remove) = [];
local_path_sl_std(idx_to_remove) = [];
local_path_len_mean(idx_to_remove) = [];
local_path_len_std(idx_to_remove) = [];
local_sl_dev_mean(idx_to_remove) = [];
local_sl_dev_std(idx_to_remove) = [];

unique_locs(idx_to_remove) = [];
label(idx_to_remove) = [];
feature_vecs = [cost, slope_dev, path_length, path_slope, length_steps, local_cost_mean, local_cost_std, local_path_sl_mean, local_path_sl_std, local_path_len_mean, local_path_len_std, local_sl_dev_mean, local_sl_dev_std];
start_loc = unique_locs;
end