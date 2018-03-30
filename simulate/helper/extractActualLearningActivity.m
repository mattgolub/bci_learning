function actualL = extractActualLearningActivity(LP_clouds)
% @ Matt Golub, 2018.

numConditions = numel(LP_clouds.cursorToTargetDirection);
nPerCloud = cellfun(@(cTTD)(size(cTTD,2)),LP_clouds.cursorToTargetDirection);

for cIdx = 1:numConditions
    meanD(:,cIdx) = mean(LP_clouds.cursorToTargetDirection{cIdx},2);
    meanD(:,cIdx) = meanD(:,cIdx)/norm(meanD(:,cIdx)); % re-normalize
    
    % Z{cIdx} = LP_clouds.factorActivity{cIdx};
    % X{cIdx} = LP_clouds.spikes{cIdx};
    D{cIdx} = repmat(meanD(:,cIdx),1,nPerCloud(cIdx));
    V{cIdx} = LP_clouds.vraw_perturbed{cIdx};
    C{cIdx} = cIdx*ones(1,nPerCloud(cIdx));
    
    actualL.P_conditionAveraged(cIdx) = mean(sum(V{cIdx}.*D{cIdx},1));
end

% Don't include these since they aren't currently used, and are not set in
% the toy data examples.

% actualL.X = [X{:}];
% actualL.Z = [Z{:}];

actualL.V = [V{:}];
actualL.D = [D{:}];
actualL.C = [C{:}];
actualL.P = sum(actualL.V.*actualL.D,1); % theoretical pre-learning cursor progress