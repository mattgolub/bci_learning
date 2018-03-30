function [m, sem, n] = meanAndSEM(x)
% @ Matt Golub, 2018.

x = x(:);
m = nanmean(x);
n = sum(~isnan(x));
sem = nanstd(x,1)/sqrt(n);