function [postLearningClouds, subselectionStats] = simulateSubselection(beforeLearningClouds,afterLearningClouds,expParams,varargin)
% Predict after-learning neural activity according to 'subselection'.
% Details are provided in the Supplementary Math Note under 'Predicting
% population activity after learning'-->'Subselection'.
%
% @ Matt Golub, 2018.

MATCH_PROGRESS = true;
ENSURE_PHYSIOLOGICAL_PLAUSIBILITY = true;
FIX_RANDOM_SEED = false;
assignopts(who,varargin);

fprintf('Generating subselection-predicted neural activity.\n');

if ~MATCH_PROGRESS
    error('simulateSubselection is not defined for max-progress. Must set MATCH_PROGRESS=1.')
end

%% Determine # points requested per after-learning movement-specific cloud
nPerCloud = getNumberOfPointsPerMovementSpecificCloud(beforeLearningClouds);

%% Draw from Gaussian mixture specified by before-learning activity

fprintf('\tObtaining pre-learning sample.\n');

LI_stats = computeCloudStats(beforeLearningClouds);
numConditions = LI_stats.numConditions;
preL = generatePreLearningActivity(expParams.perturbedMapping, LI_stats, afterLearningClouds, nPerCloud*ones(1,numConditions), ENSURE_PHYSIOLOGICAL_PLAUSIBILITY);

%% Reject patterns to match actual movement-specific progress. Then fit 
% Gaussians to the remaining samples and simulate additional samples as
% needed to attain the same number of points per conditional.

fprintf('\tDropping samples to match progress.\n');
[simL, subselectionStats] = matchProgressViaSubselection(preL,expParams.perturbedMapping,beforeLearningClouds,afterLearningClouds,varargin{:});

%% Package output
postLearningClouds = reconstructPostLearningClouds(afterLearningClouds,simL,expParams);

