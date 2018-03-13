function meanD = computeMeanCursorToTargetDirection(clouds)

numConditions = numel(clouds.cursorToTargetDirection);
nDims = size(clouds.cursorToTargetDirection{1},1);
meanD = zeros(nDims,numConditions);
for cIdx = 1:numConditions
    meanD(:,cIdx) = mean(clouds.cursorToTargetDirection{cIdx},2);
end

meanD = normalizeColumns(meanD);