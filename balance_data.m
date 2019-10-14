function [balanced_fmat,removed] = balance_data(data,skew)
% Function to balance the classes in the data. Randomly samples twice the
% number of true labels and uses. So the skew is only 1:2 in the data.

labels = data(:,12);

num_1 = numel(find(labels == 1));

ind = find(labels == 0);
index = randsample(ind, numel(ind) - num_1*skew);
removed = data(index,:);
data(index,:) = [];
balanced_fmat = data;

end