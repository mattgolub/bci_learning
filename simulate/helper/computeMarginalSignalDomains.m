function out = computeMarginalSignalDomains(stats)
% input stats should be computed from full clouds, NOT reduced clouds.
% Example:
% stats = computeCloudStats(LI_clouds);
% mSD = computeMarginalSignalDomains(stats);
% [DO NOT USE 

out.maxFactors = max(stats.signalMean,[],2);
out.minFactors = min(stats.signalMean,[],2);
out.rangeFactors = out.maxFactors-out.minFactors;

out.maxSpikes = max(stats.signalMeanSpikes,[],2);
out.minSpikes = min(stats.signalMeanSpikes,[],2);
out.rangeSpikes = out.maxSpikes-out.minSpikes;