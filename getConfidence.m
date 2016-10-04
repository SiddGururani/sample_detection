function [confidence] = getConfidence(costs, locs, step_thres, cost_thres)

locs_diff = diff(locs);
locs_diff = [1 locs_diff];
steps = find(locs_diff~=0);
steps = [steps, numel(locs)];
length_steps = diff(steps);
length_steps(end) = length_steps(end)+1;

min_in_step = zeros(1, numel(steps));
locs_in_step = zeros(1, numel(steps));
for i = 1:numel(steps)-1
    [min_in_step(i), locs_in_step(i)] = min(costs(steps(i):steps(i+1)));
    locs_in_step(i) = locs_in_step(i) + steps(i);
end
min_in_step(end) = min(costs(steps(end):end));
locs_in_step(end) = locs_in_step(end) + steps(end);

large_step_idx = find(length_steps>step_thres);

valid_minima = min_in_step(large_step_idx);
valid_locs = locs_in_step(large_step_idx);

true_detections = numel(valid_minima(valid_minima<cost_thres));

confidence = true_detections/numel(valid_minima);
end