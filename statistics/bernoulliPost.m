% Given a vector of zeros and ones, computes the posterior mean and variance 
% of probability p.
% 
%       p ~ Beta(a, b)
% x_i | p ~ Bernoulli(p)
% 
% p | {x} ~ Beta(a + number of successes, b + number of failures)
%
% Inputs:
% dat - data vector of zeros and ones
%
% Outputs:
% m   - posterior mean of p
% l   - lower limit of confidence interval, as specified by 'conf'
% u   - upper limit of confidence interval, as specified by 'conf'
%
% @ Byron Yu, May 2007

function [m, l, u] = bernoulliPost(dat, varargin)
  
  % Default is uniform prior over [0, 1]
  a    = 1;
  b    = 1;
  conf = 0.95;
  assignopts(who, varargin);
  
  anew = a + sum(dat);
  bnew = b + length(dat) - sum(dat);
  
  m = anew / (anew+bnew);
  
  edg = (1-conf)/2;
  l = betainv(edg, anew, bnew);
  u = betainv(1-edg, anew, bnew);
  
  % posterior variance
  %v = anew*bnew / (anew+bnew)^2 / (anew+bnew+1);
