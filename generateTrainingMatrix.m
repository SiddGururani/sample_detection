Train_feature_mat = [];
Train_labels = [];
for i = 1:40
    [mat,~] = featureExtract(costs{i}, locs{i}, slope_dev{i});
    Train_feature_mat = [Train_feature_mat, mat];
    Train_labels = vertcat(Train_labels, labels_all{i}');
end

% Thin out the negative classes
ind = find(Train_labels == 0);
index = randsample(ind, floor(numel(Train_labels)*0.5));
Train_labels(index) = [];
Train_feature_mat(:,index) = [];

Train_feature_mat = Train_feature_mat';