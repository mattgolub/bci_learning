function N = getNumberOfPointsPerMovementSpecificCloud(clouds)
% Determine N, as in Methods: Selecting and grouping activity patterns for
% analysis (paragraph 2, third to last sentence).

N = mode(cellfun(@(fA)(size(fA,2)),clouds.cursorToTargetDirection));
