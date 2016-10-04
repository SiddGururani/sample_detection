function [feature_matrix, locs_in_step] = featureExtract(costs, locs, slope_dev, labels)

% Get the minima in each step
locs_diff = diff([0, locs]);
% locs_diff = [1 locs_diff];
steps = find(locs_diff~=0);
steps = [steps, numel(locs)];
length_steps = diff(steps);
length_steps(end) = length_steps(end)+1;

%Normalize length of steps
norm_length_steps = length_steps / max(length_steps);

% Preallocate memory
min_in_step = ones(1, numel(length_steps));
locs_in_step = ones(1, numel(length_steps));
mean_cost_in_step = ones(1, numel(length_steps));
std_cost_in_step = ones(1, numel(length_steps));
relative_loc = ones(1, numel(length_steps));
min_slope_dev = ones(1, numel(length_steps));
min_slope_dev_diff_1 = ones(1, numel(length_steps));
% min_slope_dev_diff_2 = ones(1, numel(length_steps));

min_in_step = min_in_step*-1;
locs_in_step = locs_in_step*-1;
mean_cost_in_step = mean_cost_in_step*-1;
std_cost_in_step = std_cost_in_step*-1;
relative_loc = relative_loc*-1;
min_slope_dev = min_slope_dev*-1;
min_slope_dev_diff_1 = min_slope_dev_diff_1*-1;
% min_slope_dev_diff_2 = min_slope_dev_diff_2*-1;

% labels = zeros(1, numel(min_in_step));

% Extract features
for i = 1:numel(steps)-1
    local_costs = costs(steps(i):steps(i+1));
    local_dev = slope_dev(steps(i):steps(i+1));
    local_dev = local_dev/max(local_dev);
    dev_slope = abs(diff(local_dev));
%     [min_in_step(i), locs_in_step(i)] = min(local_costs);
    
    inv_costs = 1.01*max(local_costs) - local_costs;
    if(numel(inv_costs) < 5)
        continue;
    end
    [~,MinIdx] = findpeaks(inv_costs);
    
%     Remove minima at start or end as they aren't likely to be local
%     minima in the whole cost function
    if(numel(MinIdx) > 1)
        MinIdx(MinIdx == 1) = [];
        MinIdx(MinIdx >= numel(inv_costs)-1) = [];
    end
%     Get the minimum and the location
    Minima = local_costs(MinIdx);
    if(numel(Minima > 1))
        [min_in_step(i), idx] = min(Minima);
        locs_in_step(i) = MinIdx(idx);
        mean_cost_in_step(i) = mean(local_costs);
        std_cost_in_step(i) = std(local_costs);
        min_slope_dev(i) = local_dev(locs_in_step(i));
        min_slope_dev_diff_1(i) = dev_slope(locs_in_step(i));
%         min_slope_dev_diff_2(i) = dev_slope(locs_in_step(i)+1);
        relative_loc(i) = locs_in_step(i)/length_steps(i);
        locs_in_step(i) = locs_in_step(i) + steps(i) - 1;
    end
end

min_in_step(min_in_step == -1) = [];
norm_length_steps(mean_cost_in_step == -1) = [];
locs_in_step(mean_cost_in_step == -1) = [];
mean_cost_in_step(mean_cost_in_step == -1) = [];
std_cost_in_step(std_cost_in_step == -1) = [];
relative_loc(relative_loc == -1) = [];
min_slope_dev(min_slope_dev == -1) = [];
min_slope_dev_diff_1(min_slope_dev_diff_1 == -1) = [];
% min_slope_dev_diff_2(min_slope_dev_diff_2 == -1) = [];

% Only for training positive labels
% min_in_step(labels == 0) = [];
% norm_length_steps(labels == 0) = [];
% mean_cost_in_step(labels == 0) = [];
% std_cost_in_step(labels == 0) = [];
% relative_loc(labels == 0) = [];
% min_slope_dev(labels == 0) = [];
% min_slope_dev_diff_1(labels == 0) = [];
% min_slope_dev_diff_2(labels == 0) = [];
% labels(labels == 0) = [];

% Only for training negative labels
% min_in_step(labels == 1) = [];
% norm_length_steps(labels == 1) = [];
% mean_cost_in_step(labels == 1) = [];
% std_cost_in_step(labels == 1) = [];
% relative_loc(labels == 1) = [];
% min_slope_dev(labels == 1) = [];
% min_slope_dev_diff_1(labels == 1) = [];
% min_slope_dev_diff_2(labels == 1) = [];
% labels(labels == 1) = [];
% 
% %Take only min(100, length) of minima for negative labels
% if(numel(labels) > 100)
%     a = randsample(1:numel(labels), 100);
%     min_in_step = min_in_step(a);
%     norm_length_steps = norm_length_steps(a);
%     mean_cost_in_step = mean_cost_in_step(a);
%     std_cost_in_step = std_cost_in_step(a);
%     relative_loc = relative_loc(a);
%     min_slope_dev = min_slope_dev(a);
%     min_slope_dev_diff_1 = min_slope_dev_diff_1(a);
%     min_slope_dev_diff_1 = min_slope_dev_diff_1(a);
%     labels = labels(a);
% end

feature_matrix = zeros(5, numel(min_in_step));

feature_matrix(1,:) = min_in_step;
feature_matrix(2,:) = norm_length_steps;
feature_matrix(3,:) = mean_cost_in_step/mean(costs);
feature_matrix(4,:) = std_cost_in_step;
feature_matrix(5,:) = relative_loc;
feature_matrix(6,:) = min_slope_dev;
feature_matrix(7,:) = min_slope_dev_diff_1;
% feature_matrix(8,:) = min_slope_dev_diff_2;
% feature_matrix(6,:) = labels;

end