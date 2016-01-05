% Run using (for detection): Experiment_NMF('../Audio/sample.aif','../Audio/suspect.aif');
% or (for no detection): Experiment_NMF('../Audio/sample.aif','../Audio/0a_Suspected_Plagiarism.wav');

function [result, locations] = Experiment_NMF(sample, suspect)


[data_orig,fs] = audioread(sample);
[data_copy,fs] = audioread(suspect);
% data_orig = bsxfun(@rdivide, data_orig, rms(data_orig,1));
% data_copy = bsxfun(@rdivide, data_copy, rms(data_copy,1));
data_orig = downsample(data_orig,2);
data_copy = downsample(data_copy,2);
fs = fs/2;

%% Computing the STFT spectrograms
data_orig = mean(data_orig,2);
data_copy = mean(data_copy,2);

window = 4096;
hop = 1024;
Xo = spectrogram(data_orig, window, window-hop);
Xs = spectrogram(data_copy, window, window-hop);
% f = 0:(length(freq)-1);
% f = f*((fs/2)/length(freq));
% 
% midi = 69 + 12*log2(f/440);

%% Performing Non-negative Matrix Factorization on the original sample spectrogram

n = 0; % no pitch shifts
k = 6; 
[Bo, Ho] = nnmf(abs(Xo), k);

% Check for low-rank < k
rank_check = sum(Ho,2);
if ~isempty(find(rank_check == 0))
    Ho(find(rank_check == 0),:) = [];
    Bo(:,find(rank_check == 0)) = [];
    k = k - numel(find(rank_check == 0));
end


%% Computing pitch shifted templates for detecting pitch shifted samples
% 
% N = numel(Bo(:,1));
% Bo_concat = Bo;
% 
% % n : number of semi-tone shifts.
% n = 12; 
% for i=1:12
%     t1 = 1:N;
%     t2 = (t1)/(2^(i/12));
%     B_shift = interp1(t1, Bo, t2,'spline');
%     Bo_concat = [Bo_concat B_shift];
% end


%% Performing partially fixed NMF using the precomputed template matrix    

[Bo1, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), Bo, [], [], [], 0, 0);


%% Performing partially fixed NMF using the pitch-shift templates concatenated as well. 
%  use either one of the PFNMF sections

% [Bo1, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), Bo_concat, [], [], [], 0, 0);

%% Normalize the two activation matrices before computing correlation
% DO NOT RUN

% for i = 1:k
%     Ho(i,:) = Ho(i,:)/norm(Ho(i,:),1);
% end
% 
% for i = 1:(n+1)*k
%     Ho_hypo(i,:) = Ho_hypo(i,:)/norm(Ho_hypo(i,:),1);
% end

%% Computing correlation and subsequently the occurences between activation 
%  matrices of original sample and suspected copy

% [corrMat, instants] = FastCorrelate(Ho_hypo, Ho);
% corrMat(corrMat<0) = 0;

[corr, lags] = corr_activations(Ho,Ho_hypo);


%% Peak picking. Currently very basic hard threshold. Add better post-processing.

prod_corr = prod(corr).^(1/k);
% peak_filter = myMedianThres(prod_corr',5,0.3);
% peak_fn = prod_corr - peak_filter';
% [peaks, loc] = findpeaks(peak_fn);
[peaks, loc] = findpeaks(prod_corr);
loc(peaks<0.6) = [];
peaks(peaks<0.6) = [];

if numel(peaks) == 0
    result = 0;
    locations = 0;
    return
end
    
locations = lags(loc).*(hop/fs);
result = 1;
return

%% Computing correlation between the original activation and different pitch shifted candidates.

% corrMat = cell(n,1);
% [nr1, nc1] = size(Ho);
% [nr2, nc2] = size(Ho_hypo);
% instants = zeros(n,nc1+nc2+2);
% correlation_prod = zeros(n,nc1+nc2+2);
% peak_fn = zeros(n,nc1+nc2+2);
% for i = 1:n+1
%     %corrMat{i} = zeros(k,nc1+nc2+2);
%     %instants(i) = zeros(1,nc1+nc2+2);
%     [corrMattemp, instants(i,:)] = FastCorrelate(Ho_hypo((i-1)*k+1:i*k,:), Ho);
%     corrMattemp = corrMattemp/max([size(Ho_hypo,2), size(Ho,2)]);
%     correlation_prod(i,:) = prod(corrMattemp);
%     peak_filter = myMedianThres(correlation_prod(i,:)',4,0.30);
%     peak_fn(i,:) = correlation_prod(i,:) - peak_filter';
%     peak_fn(peak_fn(i,:)<0) = 0;
%     [strength, occurrences] = findpeaks(peak_fn(i,:));
%     
% %     figure;
% %     plot(instants(i,:),Similarity(i,:));
% 
%     figure;
%     %title();
%     plot(instants(i,:),correlation_prod(i,:));
%     hold; plot(instants(i,:), peak_filter);
% 
% %     figure;
% %     plot(instants(i,:), peak_fn(i,:));
% end

end