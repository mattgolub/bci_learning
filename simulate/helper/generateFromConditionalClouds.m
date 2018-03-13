function [simL, nRejected] = generateFromConditionalClouds(LI_clouds,LP_clouds,pertCursorParams,Zp,nPerCloud,varargin)
% nPerCloud can be a scalar or a vector

perturbedCursorParams = computeFactorPushingDirections(pertCursorParams);
M2 = perturbedCursorParams.orthonormalizedFactors;
m0 = perturbedCursorParams.offset;

LI_stats = computeCloudStats(LI_clouds);
Dmean = computeMeanCursorToTargetDirection(LP_clouds);
numConditions = LI_stats.numConditions;

if length(nPerCloud)==1
    nPerCloud = nPerCloud*ones(1,numConditions);
end

fprintf('\tGenerating from movement-specific clouds...');

nRejected = zeros(1,numConditions);
for cIdx = 1:numConditions    
    Dc{cIdx} = repmat(Dmean(:,cIdx),1,nPerCloud(cIdx));
    Cc{cIdx} = cIdx*ones(1,nPerCloud(cIdx));
    
    if any(isnan(Zp.mean(:,cIdx)))
        fprintf('\t\tCould not identify matched-progress factors. Skipping.\n');
        continue;
    end
    
    mu = Zp.mean(:,cIdx);
    Sigma = Zp.cov(:,:,cIdx);
    
    [Zc{cIdx},Xc{cIdx},nRejected(cIdx)] = simulateFactorsAndFiringRates(mu,Sigma,nPerCloud(cIdx),LI_stats,pertCursorParams,varargin{:});
end
simL.X = [Xc{:}];
simL.Z = [Zc{:}];
simL.V = bsxfun(@plus,M2*simL.Z,m0);
simL.D = [Dc{:}];
simL.C = [Cc{:}];
simL.P = sum(simL.V.*simL.D,1); % Added 3/17/17
simL.P_conditionAveraged = computeConditionAveragedProgress(simL);

fprintf('done.\n');
fprintf('\t\tAccepted: %d.\n',length(simL.C));
fprintf('\t\tRejected: %d.\n',sum(nRejected));