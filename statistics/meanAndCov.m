function [mu, Sigma] = meanAndCov(X)
% @ Matt Golub, 2018.

mu = mean(X,2);
Xc = bsxfun(@minus,X,mu);
n = size(X,2);
Sigma = (1/n)*(Xc*Xc');
end