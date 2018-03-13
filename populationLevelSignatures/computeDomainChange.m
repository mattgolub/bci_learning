function d = computeDomainChange(referencePatterns,testPatterns,K)
% Computes a normalized measure of "domain/repertoire change" to answer the
% question, "are the test patterns similar or different from the reference
% patterns?"
%
% INPUTS:
% referencePatterns: [q x N1] Matrix of reference activity patterns (columns)
% testPatterns: [q x N2] Matrix of test activity patterns (columns)
% K: [scalar] Number of nearest neighbors to consider. Distances are
%   computed to the Kth nearest neighbor.
%
% OUTPUTS:
% d: [N2 x 1]: Normalized distances from each column in testPatterns to its
% Kth nearest neighbor (column) in referencePatterns.
%
% The measure computes the Mahalanobis distance from each point (column) in
% testPatterns to its K-th nearest neightbor in referencePatterns. The 
% Mahalonobis scaling is determined by the covariance of the reference 
% patterns. These distances are then normalized by distance between 
% patterns in reference patterns. All normalized distances are returned.
%
% Values near 0 indicate that testPatterns come from a similar domain as 
% referencePatterns (i.e., they are close to those patterns relative to how
% close they are to themselves). Values >0 indicate that testPatterns come
% from a different domain. Values <0 indicate that testPatterns come from a
% subset of the domain of referencePatterns, in which referencePatterns are
% more densely sampled.
%
% Example:
% q = 86; % # of neurons
% Nref = 500;
% Ntest = 100;
% Xref = randn(q,Nref);
% Xtest = randn(q,Ntest);
% K = 5;
% mean(computeDomainChange(Xref,Xtest,K)) % This should be roughly zero [0.0410].
% mean(computeDomainChange(Xref,Xtest+1,K)) % This should be positive [0.2741].
% mean(computeDomainChange(Xref,Xtest*2,K)) % This should be positive [0.7807].
% mean(computeDomainChange(Xref,Xtest/22,K)) % This should be negative [-.3093].
%
% @ MATT GOLUB, October 2016. v 1.0.

Nref = size(referencePatterns,2);

C = cov(referencePatterns',1);
d_testToRef = nearestNeighborHelper(referencePatterns,testPatterns,C,K);
d_refToRef = nearestSelfNeighborHelper(referencePatterns,C,K);

% Rescale to account for there really being Nref-1 patterns to reference in
% nearestSelfNeighborHelper
normalizer = (Nref/(Nref-1)) * mean(d_refToRef);

d = (d_testToRef - normalizer)/normalizer;

% These are equivalent to the following, using notation from the "Learning
% by reassociation" manuscript, Methods.
% lambda*rho_t/nu - 1

% Note: taking the average of these normalized values (1) is equivalent to
% computing a single normalized mean value (2).
% (1) : mean(d)
% (2) : (mean(d_testToRef)-normalizer)/normalizer

end

function d = nearestNeighborHelper(referencePatterns,testPatterns,C,K)
% Finds the Mahalanobis distance to the Kth nearest neighbor in 
% referencePatterns for each pattern in testPatterns. Activity patterns 
% are columns of referencePatterns and testPatterns.
%
% INPUTS:
% referencePatterns: [q x N1] Matrix of reference activity patterns (columns)
% testPatterns: [q x N2] Matrix of test activity patterns (columns)
% C: [q x q] Covariance matrix used to determine Mahalanobis scaling of
%   distances.
% K: [scalar] Number of nearest neighbors to consider. Distances are
%   computed to the Kth nearest neighbor.
%
% OUTPUTS:
% d: [N2 x 1] K-nearest neighbor distances. Element j is the distance from
%   testPatterns(:,j) to its K-th nearest neighbor in referencePatterns.

[~, d] = knnsearch(referencePatterns',testPatterns','K',K,'Distance','mahalanobis','Cov',C); 

if K>1
    d = d(:,end);
end

end

function d = nearestSelfNeighborHelper(X,C,K)
% Finds the Mahalanobis distance to the Kth nearest neighbor in 
% X for each pattern in X. Activity patterns are columns of X
%
% INPUTS:
% X: [q x N] Matrix of activity patterns (columns)
% C: [q x q] Covariance matrix used to determine Mahalanobis scaling of
%   distances.
% K: [scalar] Number of nearest neighbors to consider. Distances are
%   computed to the Kth nearest neighbor.
%
% OUTPUTS:
% d: [N x 1] K-nearest neighbor distances. Element j is the distance from
%   X(:,j) to its K-th nearest neighbor in X (disregarding the 0-distance 
%   to itself)

[~, d] = knnsearch(X',X','K',K+1,'Distance','mahalanobis','Cov',C); 

if K==1
    d = d(:,2);
else
    d = d(:,end);
end

end

function d = nearestSelfNeighbor_byConditional(jointPatterns, conditionalPatterns, C, K)
% Finds the Mahalanobis distance to the Kth nearest neighbor in 
% jointPatterns for each pattern in conditionalPatterns. Activity patterns 
% are columns of jointPatterns and conditionalPatterns. The patterns in
% conditionalPatterns must be a subset of those in jointPatterns.
%
% INPUTS:
% jointPatterns: [q x N1] Matrix of reference activity patterns (columns)
% conditionalPatterns: [q x N2], N2<=N1 . Matrix of test activity patterns
%   (columns), which are assumed to be a subset of the patterns in
%   jointPatterns.
% C: [q x q] Covariance matrix used to determine Mahalanobis scaling of
%   distances.
% K: [scalar] Number of nearest neighbors to consider. Distances are
%   computed to the Kth nearest neighbor.
%
% OUTPUTS:
% d: [N2 x 1] K-nearest neighbor distances. Element j is the distance from
%   conditionalPatterns(:,j) to its K-th nearest neighbor in jointPatterns
%   (disregarding the 0-distance to itself, since that patterns in
%   conditionalPatterns are a subset of the patterns in jointPatterns.

% There is guaranteed to be at least 1 zero-distance because the joint is
% composed of the conditionals. If there are 2 or more zero-distances, that
% means a point has replicates either within the same conditional or from a
% different conditional. In either case, those zeros should be counted, but
% the "self" zero should not.
[~, d] = knnsearch(jointPatterns',conditionalPatterns','K',K+1,'Distance','mahalanobis','Cov',C); 

if K==1
    d = d(:,2);
else
    d = d(:,end);
end

end