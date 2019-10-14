training_mat = [];
training_lab = [];
testing_mat = [];
testing_lab = [];

for i=1:40
    for j = 1:20
        training_mat = [training_mat;fmat_in{i,j}];
        training_lab = [training_lab;lab_in{i,j}];
    end
end
training_mat = [training_mat, training_lab];

for i=51:80
    for j = 1:20
        testing_mat = [testing_mat;fmat_in{i,j}];
        testing_lab = [testing_lab;lab_in{i,j}];
    end
end
testing_mat = [testing_mat, testing_lab];
