x = audioread('pitch_shift_test.wav');
x_up = audioread('pitch_shift_3.wav');
x_down = audioread('pitch_shift_-3.wav');

x = mean(x,2);
x_up = mean(x_up,2);
x_down = mean(x_down,2);

X = spectrogram(x, 2048,1536);
X_up = spectrogram(x_up, 2048, 1536);
X_down = spectrogram(x_down, 2048, 1536);

pitch_shift = 3;
k = 12; % one template for each pitch class in the scale

[B, H, err] = nnmf(abs(X), k);

rank_check = sum(H,2);
if ~isempty(find(rank_check == 0))
    H(find(rank_check == 0),:) = [];
    B(:,find(rank_check == 0)) = [];
    k = k - numel(find(rank_check == 0));
end

N = numel(B(:,1));
t1 = 1:N;
t2 = (t1)/(2^(pitch_shift/12));
B_shift_up = interp1(t1, B, t2,'spline');
if t1(end)<t2(end)
    B_shift_up(floor(t1(end)/t2(end)*t1(end)):end,:) = min(B_shift_up(B_shift_up>0));
end

N = numel(B(:,1));
t1 = 1:N;
t2 = (t1)/(2^(-pitch_shift/12));
B_shift_down = interp1(t1, B, t2,'spline');
if t1(end)<t2(end)
    B_shift_down(floor(t1(end)/t2(end)*t1(end)):end,:) = min(B_shift_down(B_shift_down>0));
end
% clear Bo
%% Performing partially fixed NMF using the precomputed template matrix    

[~, Ho_hypo_up, ~, ~, err] = PfNmf(abs(X_up), B_shift_up, [], [], [], 0, 0);
[~, Ho_hypo_down, ~, ~, err] = PfNmf(abs(X_down), B_shift_down, [], [], [], 0, 0);
