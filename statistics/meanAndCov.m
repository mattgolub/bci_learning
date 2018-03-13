function [mu, Sigma] = meanAndCov(X)
mu = mean(X,2);
Xc = bsxfun(@minus,X,mu);
n = size(X,2);
Sigma = (1/n)*(Xc*Xc');
end