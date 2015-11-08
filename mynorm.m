function normMatrix = mynorm(Matrix)

normMatrix = bsxfun(@rdivide, Matrix, std(Matrix,0,2));

end