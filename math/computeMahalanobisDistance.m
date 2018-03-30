function D = computeMahalanobisDistance(Y1,Y2,C)
% D = computeMahalanobisDistance(Y1,Y2,C)
%
% Y1 and Y2 have observations as columns. They must either be the same
% size, or one must have just a single column.
%
% C is a covariance matrix.
%
% Y1, Y2 and C must have the same number of rows.
%
% @ Matt Golub, 2018.

nY1 = size(Y1,2);
nY2 = size(Y2,2);

invC = inv(C);

if nY1==nY2
    dY = Y1-Y2;
elseif nY1==1 || nY2==1
    dY = bsxfun(@minus,Y1,Y2);
else
    error('Incompatible sizes of input data');
end

D = sqrt(sum(dY.*(invC*dY),1));

% Sanity checked against: diag(pdist2(Y1',Y2','mahalanobis',C))
% Results match, but pdist2 is much slower