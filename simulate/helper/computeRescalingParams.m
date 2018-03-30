function rescalingParams = computeRescalingParams(expParams, LI_stats)
% @ Matt Golub, 2018.

intuitive.pushingVectors = computeFactorPushingDirections(expParams.intuitiveMapping);
perturbed.pushingVectors = computeFactorPushingDirections(expParams.perturbedMapping);

intuitivePMs = columnNorms(intuitive.pushingVectors.orthonormalizedFactors)';
perturbedPMs = columnNorms(perturbed.pushingVectors.orthonormalizedFactors)';

rescalingParams.deltaPMs = perturbedPMs./intuitivePMs;

%% Variance-based constraints (i.e., avg distance to means)
intuitiveTotalCov = LI_stats.covFactors;
intuitiveSignalCov = LI_stats.signalCov;

% This is the original formulation of the rescaling constraint: 
% influence per dimension does not change, where
% (influence = std * PM)
rescalingParams.totalVariances = (sqrt(diag(intuitiveTotalCov)).*(intuitivePMs./perturbedPMs)).^2;
rescalingParams.signalVariances = (sqrt(diag(intuitiveSignalCov)).*(intuitivePMs./perturbedPMs)).^2;

%% Min/Max-based constraints (i.e., marginal domains or dynamic range)
% These are more friendly for convex programming.
% For each dimension, rescale min and max signal means such that
% perturbedPMs.*perturbedSignalRange = intuitivePMs.*intuitiveSignalRange
%
% Note, unless mean of signal means is zero vector, this is NOT equivalent
% to the following:
% intuitivePM*intuitiveMax = perturbedPM*perturbedMax
% intuitivePM*intuitiveMin = perturbedPM*perturbedMin

intuitiveMaxSignalMean = max(LI_stats.signalMean,[],2);
intuitiveMinSignalMean = min(LI_stats.signalMean,[],2);
intuitiveSignalRange = intuitiveMaxSignalMean-intuitiveMinSignalMean;

perturbedSignalRange = (intuitiveSignalRange).*(intuitivePMs./perturbedPMs);
perturbedMaxSignalMean = mean(LI_stats.signalMean,2) + perturbedSignalRange/2;
perturbedMinSignalMean = mean(LI_stats.signalMean,2) - perturbedSignalRange/2;

% Sanity checks
% These should be equal
% [perturbedPMs.*(perturbedMaxSignalMean-perturbedMinSignalMean) intuitivePMs.*(intuitiveMaxSignalMean-intuitiveMinSignalMean)]
%
% These are equal only if mean(LI_stats.signalMean,2) == 0
% [intuitivePMs.*intuitiveMaxSignalMean perturbedPMs.*perturbedMaxSignalMean]
% [intuitivePMs.*intuitiveMinSignalMean perturbedPMs.*perturbedMinSignalMean]

rescalingParams.maxSignalMeans = perturbedMaxSignalMean;
rescalingParams.minSignalMeans = perturbedMinSignalMean;

end