function [ticks,lims] = getDecentTicks(xx,minNumTicks)
% xx contains the values to be shown on the axis, e.g., the data points
% themselves, the most extremal points, or preselected axis limits.
%
% See also getTicks

if nargin==1
    minNumTicks = 5; % Guaranteed to have at least this many ticks
end

minX = min(xx(:));
maxX = max(xx(:));

xRange = maxX-minX;
tickSpacingBeforeFloor = xRange/minNumTicks;

% floor spacing to the nearest N
scale = floor(log10(tickSpacingBeforeFloor));
N = 10^scale;

tickSpacing = floorToNearestN(tickSpacingBeforeFloor,N);

k = 1;

[candidateTicks{k}, deadSpace(k)] = getTicks(minX,maxX,tickSpacing);

% At this point we are guaranteed to have at least minNumTicks.
% But we might have a lot more. Let's see if we can get closer to
% minNumTicks (without falling below) by using a multiple of the tick
% spacing.
while length(candidateTicks{k})>=minNumTicks && deadSpace(k)<xRange
    k = k + 1;
    [candidateTicks{k}, deadSpace(k)] = getTicks(minX,maxX,k*tickSpacing);
end

% Eliminate candidateTicks with fewer than minNumTicks
numTicks = cellfun(@length,candidateTicks);
validCandidates = numTicks>=minNumTicks;

candidateTicks(~validCandidates) = [];
deadSpace(~validCandidates) = [];
numTicks(~validCandidates) = [];

% Of valid candidateTicks, choose the set that minimizes deadspace (i.e., 
% white space beyond the extremes of xx. In the case of a tie, choose the 
% candidateTicks with the smallest number of ticks (this is typically the \
% most visually appealing).
[sortedDeadSpace,sortIdx] = sort(deadSpace,'ascend');
minDeadSpaceIdx = sortIdx(sortedDeadSpace==sortedDeadSpace(1));
minDeadSpaceCandidateTicks = candidateTicks(minDeadSpaceIdx);
numTicks = numTicks(minDeadSpaceIdx);

[minNumTicks,minNumTicksIdx] = min(numTicks);

% These are the ticks!
ticks = candidateTicks{minNumTicksIdx};

% Suggest expanded axis limits in case they don't reach all ticks
lims = [min(minX,ticks(1)) max(maxX,ticks(end))];

end