function [train, test] = split_data(data)

labels = data(:,end);

pos_data = data(find(labels == 1),:);
neg_data = data(find(labels == 0),:);
sample_pos = randsample(size(pos_data,1), round(0.3*size(pos_data,1)));
sample_neg = randsample(size(neg_data,1), round(0.3*size(neg_data,1)));

test = [pos_data(sample_pos,:); neg_data(sample_neg,:)];
pos_data(sample_pos,:) = [];
neg_data(sample_neg,:) = [];

train = [pos_data; neg_data];

end