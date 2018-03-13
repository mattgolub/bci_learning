function metrics = computePopulationMetrics(beforeLearning, afterLearning, expParams)
% This code performs the main analyses from Golub et al, 2018. See comments
% below for correspondence to relevant figures and equations from the
% paper.
%
% @ Matt Golub, 2018.

%% Extract the orthonormalized representations of the BCI mappings (as in
% equations 21-22, and the associated footnate, of the Supplementary Math 
% Note).
intuitiveMapping = computeFactorPushingDirections(expParams.intuitiveMapping);
B = intuitiveMapping.orthonormalizedFactors; % This is B^{orth} from equation 21.

perturbedMapping = computeFactorPushingDirections(expParams.perturbedMapping);
Bpert = perturbedMapping.orthonormalizedFactors; % This is B^{pert,orth} from the footnote associated with equation 22.

%% Measure changes to the neural repertoires using equation 5.
% Measurements of overall repertoire change are presented in Fig 4, and
% measurements of movement-specific repertoire change are presented in 
% Fig 8.
[metrics.overallRepertoireChange, metrics.movementSpecificRepertoireChange] = computeRepertoireChange(beforeLearning.clouds,afterLearning.clouds);

%% Measure changes in covariance along the BCI mappings using equations 6 
% and 7. These measurements are presented in Fig 5.
[metrics.deltaVarIntuitive, metrics.deltaVarPerturbed] = computeVariabilityAlongBCIMappings(beforeLearning.clouds,afterLearning.clouds,B,Bpert);

%% Measure changes in variance along each dimension of the intrinsic
% manifold, also using equations 6 and 7. These measurements are presented,
% relative to changes in 'pushing magnitude' (equation 8) in Fig 6.
[metrics.deltaVariancePercent, metrics.deltaPushingMagnitude, metrics.slope] = computeVarianceVsPushingMagnitude(beforeLearning.clouds,afterLearning.clouds,B,Bpert);

%% Measure / predict acquisition times using equations 9 and 10. These 
% measurements and predictions are presented in Fig 7.
metrics.predictedAcqTime_beforeLearningIntuitive = computeExpectedAcquisitionTime(beforeLearning.clouds,'intuitive',expParams);
metrics.predictedAcqTime_beforeLearningPerturbed = computeExpectedAcquisitionTime(beforeLearning.clouds,'perturbed',expParams);
metrics.predictedAcqTime_afterLearningPerturbed = computeExpectedAcquisitionTime(afterLearning.clouds,'perturbed',expParams);

end