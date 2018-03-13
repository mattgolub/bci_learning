function [postLearningClouds, stats] = simulateReassociation(beforeLearningClouds,afterLearningClouds,expParams,varargin)
% Predict after-learning neural activity according to 'reassocaition'.
% Details are provided in the Supplementary Math Note under 'Predicting
% population activity after learning'-->'Reassocaition'.
%
% @ Matt Golub, 2018.

initializeSimulation

fprintf('Generating reassociation-predicted neural activity.\n');

%% Determine # points requested per after-learning movement-specific cloud
nPerCloud = getNumberOfPointsPerMovementSpecificCloud(beforeLearningClouds);

%% Rediscretize before-learning repertoire (to give more options than just 
% the before-learning movement-specific means). See step 1 under Reassociation 
% in the Supplementary Math Note.
nRediscretize = 120;
rediscretize = simulateReassociation_rediscretizeClouds(beforeLearningClouds,nRediscretize);

%% Find max-progress movement-specific means using equations 39-43.
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