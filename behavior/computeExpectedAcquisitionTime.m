function acqTime = computeExpectedAcquisitionTime(clouds,mappingStr,expParams)
% progressStr is either 'intuitive' or 'perturbed'
%
% @ Matt Golub, 2018.

progressStr = [mappingStr 'Progress'];
mappingStr = [mappingStr 'Mapping'];
progress = [clouds.(progressStr){:}]/expParams.(mappingStr).dt;
acrossConditionMeanProgress = mean(progress,2);
acqTime_0 = computePrescaledExpectedAcquisitionTime(expParams.monkName,acrossConditionMeanProgress);
acqTime = acqTime_0*expParams.lambda;

end