function scaledVals = scaleLinearlyToZeroOne(minVal, maxVal, vals)
% Linearly scale vals onto [0 1], where minVal is mapped to 0 and maxVal is
% mapped to 1. Because mapping is linear, vals outside of [minVal maxVal]
% will be mapped to values outside of [0 1].
%
% @ Matt Golub, 2018.

% compute range 
r = maxVal - minVal;
offset = minVal;
scaledVals = (vals-offset)/r;

% CHECK: Should give [0 .5 1]
% scaleLinearlyToZeroOne(minVal, maxVal, [minVal mean([minVal maxVal]) maxVal])

end