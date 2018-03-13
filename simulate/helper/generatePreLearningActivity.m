function [preL, nRejected] = generatePreLearningActivity(perturbedMapping, LI_stats, LP_clouds, nPerCloud, ENSURE_PHYSIOLOGICAL_PLAUSIBILITY)

numConditions = numel(LP_clouds.cursorToTargetDirection);

%% Find average cursor-to-target direction for each condition
% This will be used instead of timestep-by-timestep directions for
% assessing progress of simulated patterns.
for cIdx = 1:numConditions
    meanD = mean(LP_clouds.cursorToTargetDirection{cIdx},2);
    meanD = meanD/norm(meanD); % re-normalize
    Dp{cIdx} = repmat(meanD,1,nPerCloud(cIdx)); % for oversample
end

%% Draw from Gaussian mixture specified by LI clouds
[preL, nRejected] = generateFromIntuitiveClouds(LI_stats,nPerCloud,perturbedMapping,...
    'ENSURE_PHYSIOLOGICAL_PLAUSIBILITY',ENSURE_PHYSIOLOGICAL_PLAUSIBILITY);
preL.D = [Dp{:}]; % cloud-averaged cursor-to-target direction
preL.P = sum(preL.V.*preL.D,1); % theoretical pre-learning cursor progress
preL.P_conditionAveraged = computeConditionAveragedProgress(preL);