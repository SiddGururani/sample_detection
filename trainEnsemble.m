function [ens] = trainEnsemble(features, labels)

% ens = fitensemble(features, labels,'AdaBoostM1', 50, 'Tree');
ens = fitensemble(features, labels,'LogitBoost', 50, 'Tree');
cval = crossval(ens, 'kfold', 10);
kfoldLoss(cval)
end