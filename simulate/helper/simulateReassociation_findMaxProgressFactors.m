function Zp_maxProgress = simulateReassociation_findMaxProgressFactors(LI_clouds,LP_clouds,rediscretize,cursorParams,constrainSignalMeans)
% Choose signal means to be a convex combination of 120 rediscretized
% signal means, each coming from a recomputed cloud over the standard
% LI_clouds. Rediscretized clouds all contain the same number of patterns
% as the original LI_clouds, but have a finer resolution over
% cursor-to-target angles.
%
% Solution is usually a single one of those rediscretized cloud's means
% (and covariance), but occasionally that mean is not feasible under the
% signal mean constraints in the high-d firing rate space. For this reason,
% it's important to use the optimization framework rather than a faster
% brute force caluclation of progress at each rediscretized signal mean.
%
% @ Matt Golub, 2018.

fprintf('\tFinding max-progress solution subject to repertoire constraints...');

TOL = 10e-10;

factorCursorParams = computeFactorPushingDirections(cursorParams);
M2 = factorCursorParams.orthonormalizedFactors;
m0 = factorCursorParams.offset;
[Beta,mu] = extractSpikesToFactorsMapping(cursorParams);

LI_stats = computeCloudStats(LI_clouds);
nConditions = LI_stats.numConditions; % # conditions (same as # timesteps here)
[nFactors,nNeurons] = size(Beta);
nRediscretize = size(rediscretize.signalMeans,2);

%% Find mean cursor-to-target direction for each cloud
Dmean = computeMeanCursorToTargetDirection(LP_clouds); % used in optimization objective

% Sanity that these "signal means" approximately track the angles
% used to find them, when decoding rediscretized factor clouds through the
% intuitive mapping. NOTE: REQUIRES MANUALLY RECODING cursorParams TO BE
% FROM INTUITIVE MAPPING (NORMAL MODE IS FROM PERTURBED MAPPING).
%
% vAvg = bsxfun(@plus,M2*rediscretize.signalMeans,m0);
% vth = cart2pol(vAvg(1,:),vAvg(2,:));
% vth(vth<0) = vth(vth<0)+2*pi;
% scatterWithDiagonal(anglesRediscretize,rad2deg(vth));

%% Core optimization problem
cvx_begin

cvx_quiet(true)

variable Zstar(nFactors,nConditions) % post-learning factor activity
variable W(nRediscretize,nConditions) % convex weights

% Maximize total cursor progress. This is equivalent to (but faster in cvx)
maximize sum(sum((M2*Zstar + repmat(m0,1,nConditions)).*Dmean)) % total cursor progress

subject to

if constrainSignalMeans
    simulateRealignment_constrainMarginalDomains
end

% Zstar must be convex combinations of intuitive signal means
Zstar == rediscretize.signalMeans * W;
sum(W,1)==1
W>=0

cvx_end

fprintf('%s.\n',lower(cvx_status));

if ~strcmpi(cvx_status,'solved')
    error('No feasible max-progress solution.');
end

%% Package output

% Optimal cloud mean is given by solution to optimization problem
Zp_maxProgress.mean = Zstar;

% Use empirical covariance of points that went into that mean. Optimal
% weights are typically 0s and a single 1. However, there are two possibile
% cases for deviation from this rule. See (1) and (2) below.
for conditionIdx = 1:nConditions
    W_c = W(:,conditionIdx);
    idxNonZeroW = find(W_c(:)'>0);
    if length(idxNonZeroW)==1 && abs(W_c(idxNonZeroW)-1)<TOL
        % Optimal weights are 0s and a single 1.
        Sigma_c = rediscretize.noiseCovs(:,:,idxNonZeroW);
    else
        shouldBeZeroWithinTol = abs(bsxfun(@minus,rediscretize.signalMeans(:,idxNonZeroW),rediscretize.signalMeans(:,idxNonZeroW(1))));
        if ~any(shouldBeZeroWithinTol(:)>TOL)
            % (1) There are duplicate columns in rediscretize.signalMeans.
            % The data going into those columns must have been identical.
            % This means that the noise covariances are also identical.
            % Just choose one.
            Sigma_c = rediscretize.noiseCovs(:,:,idxNonZeroW(1));
        else
            % (2) Nonzero weights correspond to non-identical columns in
            % rediscretize.signalMeans. This means that the column of
            % rediscretize.signalMeans that would result in max-progress 
            % is not feasible under the constraints in 
            % simulateRealign_constrainMarginalDomains. 
            %
            % Under Reassociation, this is possible because the constraints
            % are only defined with respect to the original signal means, 
            % NOT the rediscretized means. If I decided to update the 
            % constraint to include the rediscretized means, this case 
            % would never occur under Reassociation.
            %
            % Under Rescaling (Restoring), this is very likely to be the
            % case because rediscretize reflects the rescaled neural
            % repertoire without regard for the empirical bounds on spike
            % counts. We should expect the spike count constraints to be
            % active.
            
            Sigma_c = zeros(nFactors);
            for idxNonZeroW = find(W_c(:)'>0)
                Sigma_c = Sigma_c + W_c(idxNonZeroW)*rediscretize.noiseCovs(:,:,idxNonZeroW);
            end
        end
    end
    Zp_maxProgress.cov(:,:,conditionIdx) = Sigma_c;
end

end