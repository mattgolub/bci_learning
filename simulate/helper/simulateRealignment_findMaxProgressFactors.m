function Zp_maxProgress = simulateRealignment_findMaxProgressFactors(LI_clouds,LP_clouds,cursorParams)

fprintf('\tFinding max-progress realignment solution...');

factorCursorParams = computeFactorPushingDirections(cursorParams);
M2 = factorCursorParams.orthonormalizedFactors;
m0 = factorCursorParams.offset;
[Beta,mu] = extractSpikesToFactorsMapping(cursorParams);

LI_stats = computeCloudStats(LI_clouds);
dt = LI_stats.dt;

%% Find mean cursor-to-target direction for each cloud
Dmean = computeMeanCursorToTargetDirection(LP_clouds);

nConditions = LI_stats.numConditions; % # conditions (same as # timesteps here)
[nFactors,nNeurons] = size(Beta);

%% Core optimization problem
cvx_begin

cvx_quiet(true)

variable Zstar(nFactors,nConditions) % post-learning factor activity

% Maximize total cursor progress.
maximize sum(sum((M2*Zstar + repmat(m0,1,nConditions)).*Dmean))

subject to

simulateRealignment_constrainMarginalDomains

cvx_end

fprintf('%s.\n',lower(cvx_status));

if ~strcmpi(cvx_status,'solved')
    error('No feasible max-progress solution.');
end

Zp_maxProgress.mean = Zstar;
Zp_maxProgress.cov = repmat(LI_stats.meanNoiseCov,1,1,nConditions);

end