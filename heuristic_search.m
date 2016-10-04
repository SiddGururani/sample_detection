function locations = heuristic_search(costs, locs, slope_dev)

%get steps
locs_diff = diff([0, locs]);
steps = find(locs_diff~=0);
steps = [steps, numel(locs)];
length_steps = diff(steps);
length_steps(end) = length_steps(end)+1;
length_steps(1) = length_steps(1)*2;

features = [];
%% Process each individual step. Eliminate if not sample location.
idx = find(length_steps > mean(length_steps));
temp = idx;
for i = 1:numel(temp)
    
    % Get local cost and slope deviation
    local_costs = costs(steps(temp(i)):steps(temp(i)+1));
    local_dev = slope_dev(steps(temp(i)):steps(temp(i)+1));
    local_dev = local_dev/max(local_dev);
    if(steps(temp(i)) == 1) % If starting of the song is a candidate, mirror the functions.
        local_costs = [fliplr(local_costs(2:end)), local_costs];
        local_dev = [fliplr(local_dev(2:end)), local_dev];
    end
    
    %Process cost
    [min_cost, min_cost_loc] = min(local_costs);
    
%     if(min_cost > mean(costs))
%         idx(idx == temp(i)) = [];
%         continue;
%     end
    
    % Remove step if min cost location is at the start or end of the step.
    %Process slope deviation
    if(min_cost_loc == 1 || min_cost_loc == numel(local_costs))
        idx(idx == temp(i)) = [];
        continue;
    end
    
    dev_slope = abs(diff(local_dev));
    [~, peaks] = findpeaks(smooth(dev_slope));
    
    % Check if min cost is 'near' a sudden spike in the slope_dev. 'Nearness'
    % needs a better definition
    relative_loc = abs(peaks - min_cost_loc);
    if(relative_loc <= 5)
        idx(idx == temp(i)) = [];
        continue;
    end
    
    % Check if min_cost is at a point of high slope deviation
    if(local_dev(min_cost_loc) > mean(local_dev))
        idx(idx == temp(i)) = [];
        continue;
    end
    
    % Check if min cost is at point of low second order diff of slope.
%     if(dev_slope(min_cost_loc) > mean(dev_slope))
%         idx(idx == temp(i)) = [];
%         continue;
%     end
    % Check if min cost is 'near' a local minima in slope dev (which won't be
    % a spike since that case is taken care of previously
%     [~, minima] = findpeaks(local_dev.^-1); % Find local minima of smoothed local slope deviations
%     relative_loc = abs(minima - min_cost_loc);
%     
%     if(numel(find(relative_loc <= 5)) == 0)
%         idx(idx == temp(i)) = [];
%         continue;
%     end
%     if(numel(find(relative_loc <= 1 )) == 0)
%         idx(idx == temp(i)) = [];
%     end
%     if(mean(local_costs) > mean(costs))
%         idx(idx == temp(i)) = [];
%     end
%     if(abs(min_cost_loc - min_dev_loc) > length_steps(temp(i))/2)
%         idx(idx == temp(i)) = [];
%     end

    % add to feature matrix
%     features(i) = [min_cost,min_cost_loc/length_steps(temp(i))]
end

%% Return location of the sample. Taken as the point of lowest cost within step.

% locations_1 = (steps(idx)+steps(idx+1))/2;

locations = [];
for i = 1:numel(idx)
    [~, locations(i)] = min(costs(steps(idx(i)):steps(idx(i)+1)));
    locations(i) = locations(i) + steps(idx(i));
end

end