function normMatrix = mynorm(Matrix)

Matrix = bsxfun(@minus, Matrix, mean(Matrix,2));
normMatrix = bsxfun(@rdivide, Matrix, std(Matrix,0,2));

end