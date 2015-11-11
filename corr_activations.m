function [corr, corrcoeffs, cosine_dists] = corr_activations(acti_1, acti_2)

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

positions = 0:nc2-nc1+1;

corr = zeros(nr1, numel(positions)-1);
corrcoeffs = zeros(1, numel(positions)-1);
cosine_dists = zeros(nr1, numel(positions)-1);
for i = 1:numel(positions)-1
    if i == 445
        display('hello');
    end
    corr(:,i) = sum(acti_1.*acti_2(:,i:i+nc1-1),2)./(rms(acti_1,2).*rms(acti_2(:,i:i+nc1-1),2));
    temp = corrcoef(acti_1, acti_2(:,i:i+nc1-1));
    corrcoeffs(i) = temp(1,2);
    temp = pdist2(acti_1, acti_2(:,i:i+nc1-1),'cosine');
    cosine_dists(:,i) = diag(temp);
end

end