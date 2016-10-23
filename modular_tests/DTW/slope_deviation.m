function sl_dev = slope_deviation(path)
% Computes the deviation from the average slope of a given path
av_slope = (path(end, 2) - path(1,2))/(path(end,1) - path(1,1));
dist = abs(path(2:end-1,2) - av_slope*path(2:end-1,1)) / sqrt(1 + av_slope*av_slope);
sl_dev = sum(dist);
end