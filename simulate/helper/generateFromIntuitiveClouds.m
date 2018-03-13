function [preL,nRejected] = generateFromIntuitiveClouds(LI_stats,nPerCloud,perturbedMapping,varargin)
% Generate patterns from conditional Gaussians fit to LI data.

VERBOSE = false;

numConditions = size(LI_stats.signalMean,2);
if length(nPerCloud)==1
    nPerCloud = nPerCloud*ones(1,numConditions);
end

perturbedCursorParams = computeFactorPushingDirections(perturbedMapping);
M2 = perturbedCursorParams.orthonormalizedFactors;
m0 = perturbedCursorParams.offset;

nRejected = nan(1,numConditions);
for cIdx = 1:numConditions
    if nPerCloud(cIdx)>0
        if VERBOSE
            fprintf('\t\tSampling from conditional %d of %d.\n',cIdx,numConditions);
        end
        
        mu = LI_stats.signalMean(:,cIdx)';
        Sigma = LI_stats.noiseCovs(:,:,cIdx);
        
        [Z{cIdx},X{cIdx},nRejected(cIdx)] = simulateFactorsAndFiringRates(mu,Sigma,nPerCloud(cIdx),LI_stats,perturbedMapping,varargin{:});
        
        % Labels for use when concatenating into matrix form
        C{cIdx} = repmat(cIdx,1,size(Z{cIdx},2));
    end
end

preL.Z = [Z{:}];
preL.X = [X{:}];
preL.C = [C{:}];
preL.V = bsxfun(@plus,M2*preL.Z,m0);