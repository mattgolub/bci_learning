function [deltaVariancePercent, deltaPushingMagnitude, slope] = computeVarianceVsPushingMagnitude(beforeLearningClouds,afterLearningClouds,B,Bpert)
% From varVsPM_mainTextFigure_v4.m
% Also, use varVsPM_plotExampleExperiment.m

intuitivePushingMagnitude = columnNorms(B);
perturbedPushingMagnitude = columnNorms(Bpert);

deltaPushingMagnitude =  perturbedPushingMagnitude - intuitivePushingMagnitude;

LI_activity = [beforeLearningClouds.factorActivity{:}];
LP_activity = [afterLearningClouds.factorActivity{:}];

LI_varPerDim = diag(cov(LI_activity',1));
LP_varPerDim = diag(cov(LP_activity',1));

LI_stdPerDim = sqrt(diag(cov(LI_activity',1)));
LP_stdPerDim = sqrt(diag(cov(LP_activity',1)));

deltaVariancePercent = percentChange(LI_varPerDim,LP_varPerDim)';
slope = varVsPM_computeSlopes(deltaVariancePercent,deltaPushingMagnitude);

end