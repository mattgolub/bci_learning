function rediscretize = simulateReassociate8_rediscretizeClouds(LI_clouds,nRediscretize,factorScales)
% factorScales is numFactors x 1, allows for rescaling of factors (useful
% for stretching and shrinking activity a-la-restore.

nConditions = numel(LI_clouds.factorActivity);

if nargin==3
    for conditionIdx = 1:nConditions
        LI_clouds.factorActivity{conditionIdx} = bsxfun(@times,LI_clouds.factorActivity{conditionIdx},factorScales);
    end
end
LI_stats = computeCloudStats(LI_clouds);

[nFactors,nPerCloud] = size(LI_clouds.factorActivity{1});
factorActivity = [LI_clouds.factorActivity{:}];
anglesRediscretize = linspace(0,360,nRediscretize+1);
rediscretize.angles = anglesRediscretize(1:nRediscretize);
rediscretize.signalMeans = nan(nFactors,nRediscretize);
cursorToTargetDirections = [LI_clouds.cursorToTargetDirection{:}];

% Modified from binByAngle.m
[th,r] = cart2pol(cursorToTargetDirections(1,:),cursorToTargetDirections(2,:));
angularDistance = bsxfun(@minus,th,deg2rad(rediscretize.angles)');
angularDistance(angularDistance>pi) = angularDistance(angularDistance>pi)-2*pi;
angularDistance(angularDistance<-pi) = angularDistance(angularDistance<-pi)+2*pi;

rediscretize.signalMeans = nan(nFactors,nRediscretize);
rediscretize.noiseCovs = nan(nFactors,nFactors,nRediscretize);
for angleIdx = 1:nRediscretize
    [sortAngularDistance,sortIdx] = sort(abs(angularDistance(angleIdx,:)),'ascend');
    idxKeep = sortIdx(1:nPerCloud);
    rediscretize.signalMeans(:,angleIdx) = mean(factorActivity(:,idxKeep),2);
    rediscretize.noiseCovs(:,:,angleIdx) = cov(factorActivity(:,idxKeep)',1);
end

% % Add in original signal means and noise covariances (i.e., another
% % candidate set of patterns that have realistic spread).
original.angles = LI_clouds.angles;
original.signalMeans = LI_stats.signalMean;
original.noiseCovs = LI_stats.noiseCovs;


% This confirms that the original signal means and noise covariances
% are already exactly replicated through the rediscretization.
sanityCheck_helper(original,rediscretize);

end

function sanityCheck_helper(original,rediscretize)
% Sanity check to confirm that rediscritization procedure matches original
% discritization procedure for the target directions 0,45,...
% I only check means and covariances and assume that matching both implies 
% the same set of constituent patterns (not mathematically tight, but in 
% practice impossible to imagine otherwise).

TOL = 1e-12;

for angleOriginal = original.angles(:)'
    idx_rediscretize = find(rediscretize.angles==angleOriginal);
    zbar_rediscretize = rediscretize.signalMeans(:,idx_rediscretize);
    S_rediscretize = rediscretize.noiseCovs(:,:,idx_rediscretize);
    
    idx_original = find(angleOriginal==original.angles);
    zbar_original = original.signalMeans(:,idx_original);
    S_original = original.noiseCovs(:,:,idx_original);
    
    maxErrorZbar = max(abs(zbar_rediscretize-zbar_original));
    maxErrorS = max(abs(S_rediscretize(:)-S_original(:)));
    
    if maxErrorZbar>TOL
        error('Rediscritization does not match original discretization for angle %d: %.2e',angleOriginal,maxErrorZbar);
    end
    
    if maxErrorS>10*TOL
        error('Rediscritization does not match original discretization for angle %d: %.2e.',angleOriginal,maxErrorS);
    end
end
end