function [D] = compareDistmetrics(A, B)


D1 = pdist2(A,B,'euclidean');
D2 = pdist2(A,B,'mahalanobis');
D3 = pdist2(A,B,'correlation');
D4 = pdist2(A,B,'cosine');



end