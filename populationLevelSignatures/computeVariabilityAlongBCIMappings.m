function [deltaVarIntuitive, deltaVarPerturbed] = computeVariabilityAlongBCIMappings(beforeLearningClouds,afterLearningClouds,B,Bpert)
% Modified from deltaVariance_mainTextFigureHelper.m
%
% @ Matt Golub, 2018.

intuitiveMapping.LI_varBreakdown = computePartitionedVariance([beforeLearningClouds.factorActivity{:}],B);
intuitiveMapping.LP_varBreakdown = computePartitionedVariance([afterLearningClouds.factorActivity{:}],B);

perturbedMapping.LI_varBreakdown = computePartitionedVariance([beforeLearningClouds.factorActivity{:}],Bpert);
perturbedMapping.LP_varBreakdown = computePartitionedVariance([afterLearningClouds.factorActivity{:}],Bpert);

deltaVarIntuitive = percentChange(intuitiveMapping.LI_varBreakdown.rowSpaceVariance,intuitiveMapping.LP_varBreakdown.rowSpaceVariance);
deltaVarPerturbed = percentChange(perturbedMapping.LI_varBreakdown.rowSpaceVariance,perturbedMapping.LP_varBreakdown.rowSpaceVariance);

end