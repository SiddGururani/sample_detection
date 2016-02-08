function logdist = LogDist(Mat1, Mat2)

[r1,c1] = size(Mat1);
[r2,c2] = size(Mat2);

logdist = zeros(c1,c2);

for i = 1:c1
    for j = 1:c2
        logdist(i,j) = sum(abs(log(Mat1(:,i)) - log(Mat2(:,j))));
    end
end

end