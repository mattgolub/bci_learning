function conditionalData = getConditionals(clouds,ACTIVITY_TYPE)

keyboard

for cloudIdx = 1:3
    numConditions = numel(clouds(cloudIdx).(ACTIVITY_TYPE));
    for conditionIdx = 1:numConditions
        yStr = ['Y' num2str(cloudIdx)];
        conditionalData.(yStr){conditionIdx} = clouds(cloudIdx).(ACTIVITY_TYPE){conditionIdx};
    end
end
