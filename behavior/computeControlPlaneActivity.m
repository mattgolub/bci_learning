function [projectedActivity, vraw] = computeControlPlaneActivity(concat, cursorParams)
% vraw is measured in mm/s
%
% v(t) = M1*v(t-1) + M2*u(t) + m0
% p(t) = p(t-1) + v(t-1)*dt

% 4/5/17 - Updated to work for within- and outside-manifold perturbations.
% I've kept it backwards compatibile so things are computed exactly as they
% were previously for within-manifold perturbations.
%
% For within-manifold perturbations, can use M2, m0 in spike space or in
% factor space. Results will agree (down to about 1e-8) for vraw, but
% projectedActivity will only agree down to a rotation of the data
% (I think?).

M1 = cursorParams.M1;
% scale = computeSpikesOnlyRescaling(M1); % Added 5/9/2017

if size(cursorParams.eta,1)==size(cursorParams.K,2)
    % within-manifold perturbation
    factorPushingDirections = computeFactorPushingDirections(cursorParams);
    M2 = factorPushingDirections.orthonormalizedFactors;
    m0 = factorPushingDirections.offset;
    activity = concat.orthonormalizedFactorActivity;
else
    M2 = cursorParams.M2;
    m0 = cursorParams.m0;
    activity = concat.spikes;
end

nRows = size(M2,1);
[U,S,V] = svd(M2);

nTrials = numel(activity);
for trialNo = 1:nTrials
    if isempty(activity{trialNo})
        projectedActivity{trialNo} = [];
        vraw{trialNo} = []; 
    else
        % For within-manifold
        projectedActivity{trialNo} = V(:,1:nRows)'*activity{trialNo};
        
        % These will agree regardless of which M2, m0 are used 
        vraw{trialNo} = bsxfun(@plus,M2*activity{trialNo},m0); 
    end
end