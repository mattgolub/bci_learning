function varargout = computePartitionedVariance(U, B, varargin)
% breakdown = computePartitionedVariance(U,B)
% [breakdown1, breakdown2,...] = computePartitionedVariance(U,B1,B2,...)
%
% @ Matt Golub, 2018.

Bs = {B};
for i = 1:numel(varargin)
    Bs{end+1} = varargin{i};
end

Sigma = cov(U',1);
for i = 1:numel(Bs)
    Bi = Bs{i};
    d = size(Bi,1);
    [~,~,V] = svd(Bi);
    rowSpace = V(:,1:d)';
    nullSpace = V(:,d+1:end)';
    
    rowSigma = rowSpace*Sigma*rowSpace';
    nullSigma = nullSpace*Sigma*nullSpace';
    
    breakdown.totalVariance = sum(diag(Sigma));
    breakdown.rowSpaceVariance = sum(diag(rowSigma));
    breakdown.rowSpaceFraction = breakdown.rowSpaceVariance/breakdown.totalVariance;
    breakdown.nullSpaceVariance = sum(diag(nullSigma));
    breakdown.nullSpaceFraction = breakdown.nullSpaceVariance/breakdown.totalVariance;
    
    varargout{i} = breakdown;
end
    