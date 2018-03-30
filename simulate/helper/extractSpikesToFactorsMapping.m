function [B,mu] = extractSpikesToFactorsMapping(cursorParams)
% Extracts mapping from raw spike counts to orthonormalized factors, i.e.,
% z_orth = A*bsxfun(@minus,spikes,mu)
%
% Modified from computeFactorsFromSpikes.m
%
% See also computeFactorsFromSpikes, computeSpikesFromFactors,
% simulateSpikesFromFactors.
%
% @ Matt Golub, 2018.

mu_u = cursorParams.mu_u;
Sigma_u = cursorParams.Sigma_u;
beta = cursorParams.beta;
D = cursorParams.D;
V = cursorParams.V;

B = D*V'*beta*Sigma_u;

mu = mu_u;

% Had a brief scare on 8/9/17: I misread the function header, thinking the
% desired output would be used as: 
%   z_orth = B*spikes - mu
% In that case, B is unchanged from above and mu should be:
%   mu = D*V'*beta*Sigma_u*mu_u
% However, the outputs are meant to be used as:
%   z_orth = B * (spikes - mu)
% So everything was done correctly in the first place. Of course.

% Here is the math:
%
% z_orth = D * V' * z 
%        = D*V'* beta * u_zscore
%        = D*V'*beta * Sigma_u * (spikes - mu_u)
end