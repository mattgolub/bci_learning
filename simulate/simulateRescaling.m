function [postLearningClouds, stats] = simulateRescaling(beforeLearningClouds,afterLearningClouds,expParams,varargin)
% Predict after-learning neural activity according to 'rescaling'.
% Details are provided in the Supplementary Math Note under 'Predicting
% population activity after learning'-->'Rescaling'.
%
% @ Matt Golub, 2018.

initializeSimulation

fprintf('Generating rescaling-predicted neural activity.\n');

%% Determine # points requested per after-learning movement-specific cloud
nPerCloud = getNumberOfPointsPerMovementSpecificCloud(beforeLearningClouds);

%% Determine the scale factors as defined in equation 49
LI_stats = computeCloudStats(beforeLearningClouds);
rescalingParams = computeRescalingParams(expParams, LI_stats);

%% Rescale and rediscretize the before-learning repertoire using equation 
% 48 and step 2 under Rescaling in the Supplementary Math Note, respectively.
nRediscretize = 120;
rescalingScalings = 1./rescalingParams.deltaPMs;
rediscretize = simulateReassociation_rediscretizeClouds(beforeLearningClouds,nRediscretize,rescalingScalings);

%% Find max-progress movement-specific means using step factor activity
Zp_maxProgress = simulateReassociation_findMaxProgressFactors(beforeLearningClouds,afterLearningClouds,rediscretize,expParams.perturbedMapping,true);

%% Interpolate to match progress, if desired (not explored in paper)
[Zp, stats] = simulate_matchProgress(Zp_maxProgress,beforeLearningClouds,afterLearningClouds,expParams.perturbedMapping,MATCH_PROGRESS);

%% Simulate from Gaussians specified by the movement-specific means and covariances (equations 29-31).
[simL, stats.nRejected] = generateFromConditionalClouds(beforeLearningClouds,afterLearningClouds,expParams.perturbedMapping,Zp,nPerCloud,args{:});
stats.Pstar_sim = simL.P_conditionAveraged;

%% Package output
postLearningClouds = reconstructPostLearningClouds(afterLearningClouds,simL,expParams);
stats.ZmaxProgress = Zp_maxProgress; % max-progress cloud centers

end