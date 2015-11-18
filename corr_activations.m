function [corr, lags] = corr_activations(acti_1, acti_2)

% acti_1 columns should be smaller than Acti_2 columns
[nr1, nc1] = size(acti_1);
[nr2, nc2] = size(acti_2);
if nr1~=nr2
    ME = MException('VerifyInput:InvalidInput', ...
             'The Number of rows must be equal');
	throw(ME);
end
if(nc1 > nc2)
    temp = acti_1;
    acti_1 = acti_2;
    acti_2 = temp;
    clear temp;
end

lags = -nc1:nc2+1;
acti_2 = [zeros(nr1, nc1), acti_2, zeros(nr1, nc1+1)];

corr = zeros(nr1, numel(lags));
% corrcoeffs = zeros(1, numel(lags));
% cosine_dists = zeros(nr1, numel(lags));
% corrco = zeros(1,nr1);
rms_window = zeros(nr1, numel(lags));

for i = 1:numel(lags)
    corr(:,i) = sum(acti_1.*acti_2(:,i:i+nc1-1),2);
    rms_window(:,i) = rms(acti_2(:,i:i+nc1-1),2);
%     for j = 1: nr1
%         temp = corrcoef(acti_1(j,:), acti_2(j,i:i+nc1-1));
%         corrco(j) = temp(1,2);
%     end
%     corrcoeffs(i) = mean(corrco);
%     temp = pdist2(acti_1, acti_2(:,i:i+nc1-1),'cosine');
%     cosine_dists(:,i) = diag(temp);
end

max_rms = max(rms_window,[],2);
lambda_inv =  nc1 * max_rms.*rms(acti_1,2);
corr =  bsxfun(@rdivide,corr,lambda_inv);
corr(find(isnan(corr))) = 0;
% corrcoeffs(find(isnan(corrcoeffs))) = 0;
% cosine_dists(find(isnan(cosine_dists))) = 1;
% corr(:,1) = [];
% corrcoeffs(1) = [];
% cosine_dists(:,1) = [];
% lags = lags(2:end);

%corrcoeffs = (corrcoeffs + 1)/2;
% cosine_similarity = 1-cosine_dists;


%% Plots of geometric mean of correlations or correlation coefficients for different lags
% figure;
% plot(lags,corrcoeffs);
% axis([lags(1),lags(end),-1,1]);
% figure;
% plot(lags,prod(corr).^(1/nr1));
% axis([lags(1),lags(end),0,1]);


%% Cosine... don't need to use
% figure;
% plot(lags, prod(cosine_similarity).^(1/nr1));
%axis([lags(1),lags(end),0,0.1]);
end