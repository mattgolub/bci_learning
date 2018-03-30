function [ticks, deadSpace] = getTicks(minX,maxX,tickSpacing)
% See also getDecentTicks
%
% @ Matt Golub, 2018.

maxTick = ceilToNearestN(maxX,tickSpacing);
minTick = floorToNearestN(minX,tickSpacing);
ticks = minTick:tickSpacing:maxTick;

% Deadspace: the length of the axis beyond the most extreme ticks
deadSpace = (ticks(end)-ticks(1)) - (maxX-minX);

end