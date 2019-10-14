function [activations] = extract_activations_mod(data_orig, data_copy, low_rank_sample, low_rank_mix)
% Modification is that the nmf happens once per pitch-shift instead of once
% for all pitch-shifts.
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
pitch_shifts = [-5,-3,-2,-1,0.5,1,2,3,4];
n = numel(pitch_shifts)+1;
for i=1:numel(pitch_shifts)
    t1 = 1:N;
    t2 = (t1)/(2^(pitch_shifts(i)/12));
    B_shift = interp1(t1, Bo, t2,'spline');
    B_shift(B_shift < 0) = 0;
    if t1(end)<t2(end)
        B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
    end
    % Normalize shifted templates
    b_norm = sqrt(sum(B_shift.^2,1)./size(B_shift,1));
    B_shift = bsxfun(@times, B_shift, 1./b_norm);
    Bo_concat = [Bo_concat B_shift];
end
% 
% for i=1:10 %shift up
%     t1 = 1:N;
%     t2 = (t1)/(2^(i*0.5/12));
%     B_shift = interp1(t1, Bo, t2,'spline');
%     B_shift(B_shift < 0) = 0;
%     if t1(end)<t2(end)
%         B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
%     end
%     % Normalize shifted templates
%     b_norm = sqrt(sum(B_shift.^2,1)./size(B_shift,1));
%     B_shift = bsxfun(@times, B_shift, 1./b_norm);
%     Bo_concat = [Bo_concat B_shift];
% end
% 
% for i=1:10 %shift down
%     t1 = 1:N;
%     t2 = (t1)/(2^(-i*0.5/12));
%     B_shift = interp1(t1, Bo, t2,'spline');
%     B_shift(B_shift < 0) = 0;
%     if t1(end)<t2(end)
%         B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
%     end
%     % Normalize shifted templates
%     b_norm = sqrt(sum(B_shift.^2,1)./size(B_shift,1));
%     B_shift = bsxfun(@times, B_shift, 1./b_norm);
%     Bo_concat = [Bo_concat B_shift];
% end

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

% [~, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), Bo_concat, [], [], [], low_rank_mix, 0);
Ho_hypo = [];
parfor shift = 1:n
    [~,H,~,~,err] = PfNmf(abs(Xs), Bo_concat(:,(shift-1)*k+1:shift*k), [], [], [], low_rank_mix, 0);
    Ho_hypo = [Ho_hypo; H];
end
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

% Ho = Ho./max(Ho(:));
% Ho_hypo = Ho_hypo./max(Ho_hypo(:));

% OR normalize each set of activations for different pitch shift factors
% separately
Ho = Ho./max(Ho(:));
for shift = 1:n
    H_shift = Ho_hypo((shift-1)*k+1:shift*k,:);
    H_shift = H_shift./max(H_shift(:));
    Ho_hypo((shift-1)*k+1:shift*k,:) = H_shift;
end

activations = struct();
activations.sample_H = Ho;
activations.suspect_H = Ho_hypo;
toc;
end