function expectedAcquisitionTime = computePrescaledExpectedAcquisitionTime(MONK_NAME,progress)
% Progress is in mm/s
% acqusitionTime = distance / speed
% distance = (center-to-target distance - cursor radius - target radius)
% speed = progress
%
% If progress is negative, acquisition time is infinite.
%
% @ Matt Golub, 2018.

CURSOR_RADIUS = 18; % mm
TARGET_RADIUS = 20; % mm
switch MONK_NAME
    case 'Jeffy'
        targetDistance = 151.64; % mm
    case 'Lincoln'
        targetDistance = 125; % mm
    case 'Nelson'
        targetDistance = 125; % mm
end

effectiveDistance = targetDistance - CURSOR_RADIUS - TARGET_RADIUS;

expectedAcquisitionTime = effectiveDistance./progress;
expectedAcquisitionTime(progress<0) = inf;
end