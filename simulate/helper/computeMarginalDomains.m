function out = computeMarginalDomains(stats)
% @ Matt Golub, 2018.

out.maxFactors = stats.maxFactors;
out.minFactors = stats.minFactors;
out.rangeFactors = stats.maxFactors - stats.minFactors;

out.maxSpikes = stats.maxSpikes;
out.minSpikes = stats.minSpikes;
out.rangeSpikes = stats.maxSpikes - stats.minSpikes;