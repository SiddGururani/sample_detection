function [corr, corrcoeffs, cosine_similarity] = corr_activations(acti_1, acti_2)

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
corrcoeffs = zeros(1, numel(lags));
cosine_dists = zeros(nr1, numel(lags));
corrco = zeros(1,nr1);
for i = 1:numel(lags)
    corr(:,i) = sum(acti_1.*acti_2(:,i:i+nc1-1),2)./(rms(acti_1,2).*rms(acti_2(:,i:i+nc1-1),2));
    for j = 1: nr1
        temp = corrcoef(acti_1(j,:), acti_2(j,i:i+nc1-1));
        corrco(j) = temp(1,2);
    end
    corrcoeffs(i) = mean(corrco);
    temp = pdist2(acti_1, acti_2(:,i:i+nc1-1),'cosine');
    cosine_dists(:,i) = diag(temp);
end
corr(:,1) = [];
corrcoeffs(1) = [];
cosine_dists(:,1) = [];
lags = lags(2:end);

cosine_similarity = 1-cosine_dists;

figure;
plot(lags,corrcoeffs);
figure;
plot(lags,prod(corr));
figure;
plot(lags, prod(cosine_similarity));
end