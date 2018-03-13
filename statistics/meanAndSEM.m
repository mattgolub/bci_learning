function [m, sem, n] = meanAndSEM(x)

x = x(:);
m = nanmean(x);
n = sum(~isnan(x));
sem = nanstd(x,1)/sqrt(n);