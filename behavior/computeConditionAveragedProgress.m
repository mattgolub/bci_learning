function progress = computeConditionAveragedProgress(data)
%
% @ Matt Golub, 2018.

numConditions = max(data.C);

progress = nan(1,numConditions);
for cIdx = 1:numConditions
   progress(cIdx) = mean(sum(data.V(:,data.C==cIdx).*data.D(:,data.C==cIdx),1));
end