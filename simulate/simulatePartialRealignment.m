function [postLearningClouds, stats] = simulatePartialRealignment(beforeLearningClouds,afterLearningClouds,expParams,varargin)
% Predict after-learning neural activity according to 'partial realignment'. 
% This code leverages the prediction pipeline for (complete) 'realignment'
% (equations 32-35) but with a flag setting that additionally implements
% equations 36-38. Details are provided in the Supplementary Math Note 
% under 'Predicting population activity after learning'-->'Partial Realignment'.
%
% @ Matt Golub, 2018.

fprintf('Generating partial realignment-predicted neural activity.\n\t');

[postLearningClouds, stats] = simulateRealignment(beforeLearningClouds,afterLearningClouds,expParams,'MATCH_PROGRESS',true,varargin{:});

end