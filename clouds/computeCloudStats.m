function stats = computeCloudStats(clouds)
%
% @ Matt Golub, 2018.

X = [clouds.spikes{:}]; % spikes
Z = [clouds.factorActivity{:}]; % factor activity
D = [clouds.cursorToTargetDirection{:}]; % cursor-to-target directions
V = [clouds.vraw_intuitive{:}]; % raw cursor velocities

numConditions = numel(clouds.factorActivity);
stats.numConditions = numConditions;

% Factor stats
stats.minFactors = min(Z,[],2);
stats.maxFactors = max(Z,[],2);
stats.meanFactors = mean(Z,2);
stats.covFactors = cov(Z',1);

% Spike stats
stats.minSpikes = min(X,[],2);
stats.maxSpikes = max(X,[],2);
stats.meanSpikes = mean(X,2);
stats.covSpikes = cov(X',1);

for conditionIdx = 1:numConditions
    % Conditional means
    stats.signalMean(:,conditionIdx) = mean(clouds.factorActivity{conditionIdx},2);
    stats.signalMeanSpikes(:,conditionIdx) = mean(clouds.spikes{conditionIdx},2);
    
    % Conditional covariances
    stats.noiseCovs(:,:,conditionIdx) = cov(clouds.factorActivity{conditionIdx}',1);
    
    % Mahalanobis distances from cloud means under cloud covariances
    meanMDist = mean(computeMahalanobisDistance(clouds.factorActivity{conditionIdx},stats.signalMean(:,conditionIdx),stats.noiseCovs(:,:,conditionIdx)));
    stats.mahalanobisDistance(conditionIdx) = meanMDist;
    
    % Progress
    stats.meanIntuitiveProgress(1,conditionIdx) = mean(clouds.intuitiveProgress{conditionIdx});
    stats.meanPerturbedProgress(1,conditionIdx) = mean(clouds.perturbedProgress{conditionIdx});
end

% Mean of conditional covariances
stats.meanNoiseCov = squeeze(mean(stats.noiseCovs,3));

% Covariance of conditional means
stats.signalCov = cov(stats.signalMean',1);

% Recover DT from two different scalings of cursor progress
if isfield(clouds,'intuitiveProgress') % i.e., not toy data
    P1 = sum([clouds.vraw_intuitive{:}].*[clouds.cursorToTargetDirection{:}],1);
    P2 = [clouds.intuitiveProgress{:}];
    stats.dt = median(P2./P1);
else
    % toy data
    stats.dt = 1;
end

end