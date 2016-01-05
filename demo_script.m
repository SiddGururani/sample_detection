suspect1 = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/01.wav';
sample = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_sample/01.wav';
suspect2 = 'C:/Users/SiddGururani/Desktop/Stevie wonder samples/Inorganic Dataset/New_songs/02.wav';

[data_orig,fs] = audioread(sample);
[data_copy1,fs] = audioread(suspect1);
[data_copy2,fs] = audioread(suspect2);
% data_orig = bsxfun(@rdivide, data_orig, rms(data_orig,1));
% data_copy = bsxfun(@rdivide, data_copy, rms(data_copy,1));
data_orig = downsample(data_orig,2);
data_copy1 = downsample(data_copy1,2);
data_copy2 = downsample(data_copy2,2);

fs = fs/2;

%% Computing the STFT spectrograms
data_orig = mean(data_orig,2);
data_copy1 = mean(data_copy1,2);
data_copy2 = mean(data_copy2,2);

window = 4096;
hop = 1024;
Xo = spectrogram(data_orig, window, window-hop);
Xs1 = spectrogram(data_copy1, window, window-hop);
Xs2 = spectrogram(data_copy2, window, window-hop);

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
figure; imagesc([1:size(Ho,2)].*hop/fs,[2048:0],(abs(Xo))); xlabel('Time (s)'); ylabel('Frequency Bin');title('Magnitude Spectrogram of Sample');

hFig = figure;
set(hFig, 'Position', [450 100 1000 800])
subplot(2,3,1); plot(Bo(:,1)); xlabel('Frequency Bin'); ylabel('Magnitude'); title('First Template'); xlim([0, 2049]);
subplot(2,3,2); plot(Bo(:,2)); xlabel('Frequency Bin'); ylabel('Magnitude'); title('Second Template'); xlim([0, 2049]);
subplot(2,3,3); plot(Bo(:,3)); xlabel('Frequency Bin'); ylabel('Magnitude'); title('Third Template'); xlim([0, 2049]);
subplot(2,3,4); plot(Bo(:,4)); xlabel('Frequency Bin'); ylabel('Magnitude'); title('Fourth Template'); xlim([0, 2049]);
subplot(2,3,5); plot(Bo(:,5)); xlabel('Frequency Bin'); ylabel('Magnitude'); title('Fifth Template'); xlim([0, 2049]);
subplot(2,3,6); plot(Bo(:,6)); xlabel('Frequency Bin'); ylabel('Magnitude'); title('First Template'); xlim([0, 2049]);
suptitle('Factorized Sample Spectrogram to Get Templates');

hFig = figure;
set(hFig, 'Position', [450 100 1000 800])
subplot(2,3,1); plot([1:size(Ho,2)].*hop/fs,Ho(1,:)); xlabel('Time (s)'), ylabel('Magnitude'); title('First Activation');
subplot(2,3,2); plot([1:size(Ho,2)].*hop/fs,Ho(2,:)); xlabel('Time (s)'), ylabel('Magnitude'); title('Second Activation');
subplot(2,3,3); plot([1:size(Ho,2)].*hop/fs,Ho(3,:)); xlabel('Time (s)'), ylabel('Magnitude'); title('Third Activation');
subplot(2,3,4); plot([1:size(Ho,2)].*hop/fs,Ho(4,:)); xlabel('Time (s)'), ylabel('Magnitude'); title('Fourth Activation');
subplot(2,3,5); plot([1:size(Ho,2)].*hop/fs,Ho(5,:)); xlabel('Time (s)'), ylabel('Magnitude'); title('Fifth Activation');
subplot(2,3,6); plot([1:size(Ho,2)].*hop/fs,Ho(6,:)); xlabel('Time (s)'), ylabel('Magnitude'); title('Sixth Activation');
suptitle('Factorized Sample Spectrogram to Get Activations');

figure; imagesc([1:size(Ho,2)].*hop/fs,[0:2048],(Bo*Ho)); xlabel('Time (s)'); ylabel('Frequency Bin'); title('Reconstructed Magnitude Spectrogram of Sample');

fprintf('Press a key to continue...\n');
pause;

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

[Bo1, Ho_hypo1, ~, ~, err] = PfNmf(abs(Xs1), Bo, [], [], [], 0, 0);
[Bo1, Ho_hypo2, ~, ~, err] = PfNmf(abs(Xs2), Bo, [], [], [], 0, 0);
figure; imagesc([1:size(Ho_hypo1,2)].*hop/fs,[0:2048],(Bo*Ho_hypo1)); xlabel('Time (s)'); ylabel('Frequency Bin'); title('Reconstructed Spectrogram of Sample using Song Activations: Match');
figure; imagesc([1:size(Ho_hypo2,2)].*hop/fs,[0:2048],(Bo*Ho_hypo2)); xlabel('Time (s)'); ylabel('Frequency Bin'); title('Reconstructed Spectrogram of Sample using Song Activations: No Match');
fprintf('Press a key to continue...\n');
pause;

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

[corr1, lags1] = corr_activations(Ho,Ho_hypo1);
figure; plot(lags1*1024/22050,corr1); xlabel('Time (s)'); ylabel('Correlation'); title('6 Correlation Functions Between Corresponding Activations: Match');

[corr2, lags2] = corr_activations(Ho,Ho_hypo2);
figure; plot(lags2*1024/22050,corr2); xlabel('Time (s)'); ylabel('Correlation'); title('6 Correlation Functions Between Corresponding Activations: No Match');

fprintf('Press a key to continue...\n');
pause;
%% Peak picking. Currently very basic hard threshold. Add better post-processing.

prod_corr1 = prod(corr1).^(1/k);
% peak_filter = myMedianThres(prod_corr',5,0.3);
% peak_fn = prod_corr - peak_filter';
% [peaks, loc] = findpeaks(peak_fn);
[peaks1, loc] = findpeaks(prod_corr1);
loc(peaks1<0.6) = [];
peaks1(peaks1<0.6) = [];
figure; plot(lags1*1024/22050,prod_corr1); xlabel('Time (s)'); ylabel('Correlation'); title('Geometric Mean of Correlations for all Activations: Match');

prod_corr2 = prod(corr2).^(1/k);
% peak_filter = myMedianThres(prod_corr',5,0.3);
% peak_fn = prod_corr - peak_filter';
% [peaks, loc] = findpeaks(peak_fn);
[peaks2, loc] = findpeaks(prod_corr2);
loc(peaks2<0.6) = [];
peaks2(peaks2<0.6) = [];
figure; plot(lags2*1024/22050,prod_corr2); xlabel('Time (s)'); ylabel('Correlation'); title('Geometric Mean of Correlations for all Activations: No Match');

