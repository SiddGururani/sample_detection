%1 Sample kept the same. Suspect time stretched
% sample = '../Audio/sample.aif';
% suspect = '../Audio/time.wav';
% suspect = '../Audio/suspect.aif';
% suspect = '../Audio/0a_Suspected_Plagiarism.wav';

%2 Sample time stretched. Suspect kept the same
sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/01.wav';
% sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/Time-stretched/01.wav';
% suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';
suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';

%3 Sample time stretched. Suspect kept the same
% sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/02.wav';
% sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/Time-stretched/02.wav';
% suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';
% suspect = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';

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
[Xo, freq, time] = spectrogram(data_orig, window, window-hop);
Xs = spectrogram(data_copy, window, window-hop);

clear data_orig data_copy
f = 0:(length(freq)-1);
f = f*((fs/2)/length(freq));

midi = 69 + 12*log2(f/440);

%% Performing Non-negative Matrix Factorization on the original sample spectrogram

n = 0; % no pitch shifts
k = 10; 
[Bo, Ho, r] = nnmf(abs(Xo), k);

% Check for low-rank < k
rank_check = sum(Ho,2);
if ~isempty(find(rank_check == 0))
    Ho(find(rank_check == 0),:) = [];
    Bo(:,find(rank_check == 0)) = [];
    k = k - numel(find(rank_check == 0));
end

%% Computing pitch shifted templates for detecting pitch shifted samples

% N = numel(Bo(:,1));
% Bo_concat = Bo;
% 
% % n : number of semi-tone shifts.
% n = 12; 
% for i=1:12
%     t1 = 1:N;
%     t2 = (t1)/(2^(-i/12));
%     B_shift = interp1(t1, Bo, t2,'spline');
% %     if t1(end)<t2(end)
% %         B_shift(floor(t1(end)/t2(end)*t1(end)):end,:) = 0;
% %     end
%     Bo_concat = [Bo_concat B_shift];
% end
% 
% clear B_shift Bo

%% Performing partially fixed NMF using the precomputed template matrix    

[Bo1, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), Bo, [], [], [], 0, 0);


%% Performing partially fixed NMF using the pitch-shift templates concatenated as well. 
%  use either one of the PFNMF sections

% [~, Ho_hypo, ~, ~, err] = PfNmf(abs(Xs), Bo_concat, [], [], [], 0, 0);

%% Normalize the two activation matrices before computing correlation
% DO NOT RUN

for i = 1:k
    Ho(i,:) = Ho(i,:)/norm(Ho(i,:),1);
end

for i = 1:(n+1)*k
    Ho_hypo(i,:) = Ho_hypo(i,:)/norm(Ho_hypo(i,:),1);
end

%% time stretch detection
tic;
D = pdist2(Ho', Ho_hypo','correlation');
costs = zeros(1,size(Ho_hypo,2)- floor(size(Ho,2)/4));
locs = zeros(1,size(Ho_hypo,2) - floor(size(Ho,2)/4));
% p = cell(size(Ho_hypo,2),1);
for i=1:(size(Ho_hypo,2) - floor(size(Ho,2)/4));
	[a,c] = DTW(D(:,i:end));
%     p{i} = a;
	[costs(i), locs(i)] = min(c(end,:));
    locs(i) = locs(i) + i;
    costs(i) = costs(i)/size(a,1);
end
toc;

% code for including the step length for cost computation
locs_diff = diff(locs);
locs_diff = [1 locs_diff];
steps = find(locs_diff~=0);
length_steps = diff(steps);
for i = 1:numel(costs)
    for j = 2:numel(steps)
        if(i < step(j))
            costs(i) = costs(i)/length_steps(j-1);
        end
    end
end
inv_c = costs.^(-1);
[~,ind] = sort(inv_c);