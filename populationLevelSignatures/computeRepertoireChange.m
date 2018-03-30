function [overallRepertoireChange, movementSpecificRepertoireChange] = computeRepertoireChange(LI_clouds, LP_clouds)
%
% @ Matt Golub, 2018.

K = 5;
numConditions = numel(LI_clouds.factorActivity);
jointReferencePatterns = [LI_clouds.factorActivity{:}];

for conditionIdx = 1:numConditions
    conditionalReferencePatterns = LI_clouds.factorActivity{conditionIdx};
    conditionalTestPatterns = LP_clouds.factorActivity{conditionIdx};
    % Across-movement repertoire change (i.e., change in the joint)
    jointD = computeDomainChange(jointReferencePatterns,conditionalTestPatterns,K);
    overallRepertoireChange(conditionIdx) = mean(jointD);
    
    % Within-movement repertoire change (i.e., change in the conditionals)
    conditionalD = computeDomainChange(conditionalReferencePatterns,conditionalTestPatterns,K);
    movementSpecificRepertoireChange(conditionIdx) = mean(conditionalD);
end