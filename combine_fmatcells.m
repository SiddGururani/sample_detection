function [feature_mat] = combine_fmatcells(fmat_cells, label_cells)

num = size(fmat_cells,2);
feature_mat = [];

for i = 1:num
    feature_mat = [feature_mat; [fmat_cells{i}, label_cells{i}]];

end