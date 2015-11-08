%% Adaptive threshold: median filter
% [thres] = myMedianThres(nvt, order, lambda)
% input: 
%   nvt: m by 1 float vector, the novelty function
%   order: int, size of the sliding window in samples
%   lambda: float, a constant coefficient for adjusting the threshold
% output:
%   thres = m by 1 float vector, the adaptive median threshold

function [thres] = myMedianThres(nvt, order, lambda)
% YOUR CODE HERE: 

% Padding zeros before and after the Novelty function for window centering
nvt_pad = [zeros(floor(order/2),1); nvt; zeros(floor(order/2),1)];

DC_thres = max(nvt)*lambda;
thres = DC_thres*ones(numel(nvt),1);
for i = 1:numel(nvt)-1
    window = nvt_pad(i:i+order);
    thres(i) = thres(i) + median(window);
end

end