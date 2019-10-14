function pitch = exp_determine_pitch_shift(Ho, H_all)

k = size(Ho,1); % Rank
n = size(H_all,1)/k; % Number of pitch_shifts

a = [0,-5,-3,-2,-1,0.5,1,2,3,4];

[~,ind] = max(max(H_all,[],2));
pitch = a(ceil(ind/n));
end