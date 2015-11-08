% Run using (for detection): Experiment_NMF('Audio/sample.aif','Audio/suspect.aif');
% or (for no detection): Experiment_NMF('Audio/sample.aif','Audio/0a_Suspected_Plagiarism.wav');

function Experiment_NMF(sample, suspect)


[data_orig,fs] = audioread(sample);
[data_copy,fs] = audioread(suspect);

%% Computing the STFT spectrograms

[Xo, freq, time] = spectrogram(data_orig(:,1), 2048, 2048-512);
Xs = spectrogram(data_copy(:,1), 2048, 2048-512);
f = 0:(length(freq)-1);
f = f*((fs/2)/length(freq));

midi = 69 + 12*log2(f/440);

%% Performing Non-negative Matrix Factorization on the original sample spectrogram

n = 0; % no pitch shifts
k = 10; 
[Bo, Ho] = nnmf(abs(Xo), k);

%% Computing pitch shifted templates for detecting pitch shifted samples

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

[corrMat, instants] = FastCorrelate(Ho_hypo, Ho);
corrMat(corrMat<0) = 0;

%normalize corrMat: method 1 :- z-score normalization. Don't use. Weird.
normcorrMat1 = mynorm(corrMat);

%normalize corrMat: method 2 :- Normalize by standard deviation of sample
%activation and whole activations of suspect. Discussed in meeting.
normcorrMat2 = bsxfun(@rdivide,corrMat,(std(Ho_hypo,0,2).*std(Ho,0,2)));

%normalize corrMat: method 3 :- Normalize by RMS. Discussed in e-mail.
normcorrMat3 = bsxfun(@rdivide, corrMat, rms(corrMat,2));

correlation_prod1 = prod(normcorrMat1); 
correlation_prod2 = prod(normcorrMat2); 
correlation_prod3 = prod(normcorrMat3); 

figure;
plot(instants,correlation_prod1);

figure;
plot(instants,correlation_prod2);

figure;
plot(instants,correlation_prod3);

%[strength, occurrences] = findpeaks(correlation_prod);

% figure;
% plot(instants,correlation_prod);
% hold; plot(instants, peak_filter);
% 
% figure;
% plot(instants, peak_fn);

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