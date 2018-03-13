function hypothesis = generateHypothesisPredictions(hypothesisName,beforeLearning,afterLearning,expParams)
% This is just a helper function that points to other code to do the heavy
% lifting.
% 
% @ Matt Golub, 2018.

hypothesis.name = hypothesisName;
simulateFcn = getSimulateFcn(hypothesisName);
[hypothesis.clouds, hypothesis.stats] = simulateFcn(beforeLearning.clouds,afterLearning.clouds,expParams);
