function [PDs, maxMagnitude] = computeFactorPushingDirections(cursorParams)
% Computes pushing directions for factors from Batista lab
% shuffle experiments. FOR FACTOR SHUFFLES ONLY as of 8/4/15
%
% The following code reconstructs unsmoothed cursor velocities (M2*u+m0)
% from raw spikes, factors, and orthonormalized factors.
% v0 = bsxfun(@plus,cursorParams.M2*u,cursorParams.m0);
% v1 = bsxfun(@plus,pushingDirections.factors*z,-cursorParams.K*cursorParams.d);
% v2 = bsxfun(@plus,pushingDirections.factors*cursorParams.V*inv(cursorParams.D)*z_orth,-cursorParams.K*cursorParams.d);
%
% @ Matt Golub, 2018.

K = cursorParams.K; % KF Kalman gain. 
d = cursorParams.d; % KF Observation model offset
Sigma_z = cursorParams.Sigma_z; % Factor normalization matrix, diagonals are 1/std(z_i)
eta = cursorParams.eta; % Factor permutation matrix. A single 1 per row and column.

% [U,D,V] = svd(Lambda), where Lambda is the factor loadings 
% (learned from normalized spike counts)
U = cursorParams.U;
D = cursorParams.D;
V = cursorParams.V;

numFactors = size(Sigma_z,1);
invD = diag(1./diag(D));

PDs.factors = K*eta*Sigma_z;
PDs.orthonormalizedFactors = PDs.factors*V*invD;
PDs.offset = -K*d; % corrected 11/3/2015 (was: -D*d)

% Above is equivalent to passing axis-aligned unit vector factors through
% the factor-based and orthonormalized-factor-based decoders:
% for factorIdx = 1:numFactors
%     z = zeros(numFactors,1);
%     z(factorIdx) = 1;
%     PDs.factors(:,factorIdx) = K*eta*Sigma_z*z; % See reconstructDecodeUsingFactors.m     
%     PDs.orthonormalizedFactors(:,factorIdx) = K*eta*Sigma_z*V*invD*z; % See reconstructDecodeUsingFactors.m
% end

maxMagnitude = max(columnNorms(PDs.orthonormalizedFactors));

% For factor shuffles, the perturbed pushing direction is simply the following reindexing
% THIS IS WRONG. WHY?
% shuffleIdx = rawData.simpleData.shuffles.shuffles;
% perturbedPushingDirections.factors(:,shuffleIdx) = pushingDirections.factors;
% perturbedPushingDirections.orthonormalizedFactors(:,shuffleIdx) = pushingDirections.orthonormalizedFactors;
