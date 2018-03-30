function [hull,X_enclosed,X_outliers] = plotConvexHull(X,varargin)
% X is 2xn
%
% Additional input options include:
% 'FRACTION_ENCLOSED': Scalar between 0 and 1 specifying the fraction of
% data to enclose in the convex hull. Default: 1. Data points that actively
% define the convex hull are dropped (in an ad-hoc method) until the convex
% hull encloses the desired fraction of the data. Using values less than 1
% reduces the hull's sensitivity to extremal values.
%
% @ Matt Golub, 2018.

FRACTION_ENCLOSED = 1;
plotArgs = assignopts(who,varargin);

[K,V,K_outliers] = convhull_removeOutliers(X',FRACTION_ENCLOSED);
hull = X(:,K);

K_inliers = setdiff(1:size(X,2),K_outliers)';
X_enclosed = X(:,K_inliers);
X_outliers = X(:,K_outliers);

plot(hull(1,:),hull(2,:),plotArgs{:});
end
