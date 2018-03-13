function [postLearningClouds, stats] = simulateRealignment(beforeLearningClouds,afterLearningClouds,expParams,varargin)
% Predict after-learning neural activity according to 'realignment'. This
% code implements equations 32-35. This code is also used for 'partial
% realignment,' which additionally implements equations 36-38. 
% Details are provided in the Supplementary Math Note under 'Predicting
% population activity after learning'-->'Realignment'.
%
% @ Matt Golub, 2018.

initializeSimulation

fprintf('Generating realignment-predicted neural activity.\n');

%% Determine # points requested per after-learning movement-specific cloud.
nPerCloud = getNumberOfPointsPerMovementSpecificCloud(beforeLearningClouds);

%% Find max-progress mean factor activity for each movement-specific cloud.
% This solves the optimization problem of equations 32-34.
Zp_maxProgress = simulateRealignment_findMaxProgressFactors(beforeLearningClouds,afterLearningClouds,expParams.perturbedMapping);

%% Interpolate to match progress (for partial realignment) using equations 36-38.
[Zp, stats] = simulate_matchProgress(Zp_maxProgress,beforeLearningClouds,afterLearningClouds,expParams.perturbedMapping,MATCH_PROGRESS);

%% Simulate from Gaussians specified by the movement-specific means and covariances (equations 29-31).
[simL, stats.nRejected] = generateFromConditionalClouds(beforeLearningClouds,afterLearningClouds,expParams.perturbedMapping,Zp,nPerCloud,args{:});
stats.Pstar_sim = simL.P_conditionAveraged;

%% Package output.
postLearningClouds = reconstructPostLearningClouds(afterLearningClouds,simL,expParams);
stats.ZmaxProgress = Zp_maxProgress; % max-progress cloud centers

end