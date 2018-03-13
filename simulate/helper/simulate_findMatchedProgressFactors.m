function [Zp,stats] = simulate_findMatchedProgressFactors(Zmax, LI_clouds,LP_clouds,cursorParams)
% Zmax is solution from simulate*_findMaxProgressFactors
%
% Interpolate between LI and max-progress movement-specific means to match
% observed progress. Essentially a line search.

fprintf('\tInterpolating up to max-progress solution to match progress...');

LI_stats = computeCloudStats(LI_clouds);
dt = LI_stats.dt;

Dmean = computeMeanCursorToTargetDirection(LP_clouds);

factorCursorParams = computeFactorPushingDirections(cursorParams);
M2 = factorCursorParams.orthonormalizedFactors;
m0 = factorCursorParams.offset;
[Beta,mu] = extractSpikesToFactorsMapping(cursorParams);
[nFactors,nNeurons] = size(Beta);

nConditions = LI_stats.numConditions;
Zp.mean = nan(nFactors,nConditions);
Zp.cov = nan(nFactors,nFactors,nConditions);
Xstar = nan(nNeurons,nConditions);
alpha = nan(1,nConditions); % convex combination weights
for cIdx = 1:nConditions
    
    Pdes = mean(LP_clouds.perturbedProgress{cIdx},2)/dt; % cursor progress, mm/s
    D = Dmean(:,cIdx);
    Z0 = mean(LI_clouds.factorActivity{cIdx},2);
    
    [Zp.mean(:,cIdx),Xstar(:,cIdx),alpha(cIdx),progress] = solveHelperSimple(D,Pdes,Z0,Zmax.mean(:,cIdx),M2,m0,Beta,mu,LI_stats);
    % [Zp.mean(:,cIdx),Xstar(:,cIdx),alpha(cIdx),progressGap(cIdx)] = solveHelper(D,P,Z0,Zmax.mean(:,cIdx),M2,m0,Beta,mu,LI_stats);
    
    % Interpolate noise covariance so zero learning matches LI.
    Sigma0 = LI_stats.noiseCovs(:,:,cIdx);
    SigmaMax = Zmax.cov(:,:,cIdx);
    
    % Interpolate between covariances
    Zp.cov(:,:,cIdx) = alpha(cIdx)*SigmaMax + (1-alpha(cIdx))*Sigma0;
    
    % Interpolate between sqrt covariances (tried when debugging perturbed
    % projected variance for reassociate).
    %     sqrtSigma0 = sqrtm(Sigma0);
    %     sqrtSigmaMax = sqrtm(Zmax.cov(:,:,cIdx));
    %     sqrtSigmaMatched = alpha(cIdx)*sqrtSigmaMax + (1-alpha(cIdx))*sqrtSigma0;
    %     Zp.cov(:,:,cIdx) = sqrtSigmaMatched*sqrtSigmaMatched;
        
    % All in mm/s
    stats.P0(cIdx) = progress.P0;
    stats.Pact(cIdx) = progress.Pact;
    stats.Pstar(cIdx) = progress.Pstar;
    stats.Pmax(cIdx) = progress.Pmax;
    stats.progressGap(cIdx) = progress.gap;
end

stats.alpha = alpha;

fprintf('done.\n');
end

function [Zstar,Xstar,aStar,progressGap] = solveHelper(D,P,Z0,Zmax,M2,m0,Beta,mu,LI_stats)
% The following inputs are specific to this condition
% V: actual cursor velocities
% D: actual cursor-to-target directions
% P: actual cursor progress values
% Z0: LI mean factor activity
% Zmax: Max-progress factor activity

% CAN'T UNDERSTAND WHY, BUT SOMETIMES THIS BEHAVES UNPREDICABLY,
% DEGENERATING TO aStar=0, WHEN solveHelperSimple FINDS A BETTER SOLUTION.

nConditions = LI_stats.numConditions;
nFactors = size(M2,2);
nNeurons = length(mu);
nDimsKinematics = size(D,1);

%% Core optimization problem
cvx_begin

cvx_quiet(true)

variable Vstar(nDimsKinematics,1) % post-learning raw velocity
variable Zstar(nFactors,1) % post-learning factor activity
variables aStar Pstar

minimize norm(Pstar - P)
% minimize norm(Zstar-Zmax)

subject to

Vstar == M2*Zstar + m0; % velocity from factors
Pstar == sum(Vstar.*D)

% Linear interpolation between Z0 and Zmax
Zstar == (1-aStar)*Z0 + aStar*Zmax
aStar >= 0
aStar <= 1

% Already know that Z0 and Zmax are within the marginal domains.
% (unless sR_findMaxProgressFactors fails!!! This happened.)
simulateRealign_constrainMarginalDomains

cvx_end

progressGap = P-Pstar;

if abs(progressGap)>10e-4
    plotLineSearchDebug(Zstar,aStar,Pstar,Z0,Zmax,P,D,M2,m0,domainToApply)
end

end

function [Zstar,Xstar,aStar,progress] = solveHelperSimple(D,Pact,Z0,Zmax,M2,m0,Beta,mu,LI_stats)
% If Zmax and Z0 are both feasible points under the linear constraints,
% then any convex combination of those points is also feasible. Thus, we
% don't need to solve a constrained optimization problem!

% Compute zero-learning progress
V0 = M2*Z0+m0;
P0 = sum(V0.*D);

% Compute max-learning progress
Vmax = M2*Zmax+m0;
Pmax = sum(Vmax.*D);

% Interpolate between zero- and max-learning (force to be within bounds)
aStar = scaleLinearlyToZeroOne(P0,Pmax,Pact);
aStar = max(0,min(aStar,1));

Zstar = aStar*Zmax + (1-aStar)*Z0;
Vstar = M2*Zstar+m0;
Pstar = sum(Vstar.*D);
[Xstar, feas] = computeFeasibleSpikes_local_linprog(Zstar,LI_stats,Beta,mu);
% [Xstar2, feas2] = computeFeasibleSpikes_local_cvx(Zstar,LI_stats,Beta,mu);

progress.P0 = P0;
progress.Pact = Pact;
progress.Pstar = Pstar;
progress.Pmax = Pmax;
progress.gap = Pact-Pstar;

end

function [spikes,isfeasible] = computeFeasibleSpikes_local_cvx(candidateFactorActivity,observedStats,Beta,mu)
% Borrowed from computeFeasibleSpikesFromFactors

q = size(Beta,2); % # of neurons
n = size(candidateFactorActivity,2); % # of timesteps

spikesMin = repmat(observedStats.minSpikes,1,n); % needed for assembling disciplined constraints
spikesMax = repmat(observedStats.maxSpikes,1,n); % needed for assembling disciplined constraints

cvx_begin

cvx_quiet(true);

variable spikes(q,n) % post-learning pseudo spike counts (not integers)

Beta*(spikes - repmat(mu,1,n)) == candidateFactorActivity; % Spikes to orthonormalized factors

spikesMin <= spikes; % Lower bound on spike counts for each neuron
spikes <= spikesMax; % Upper bound on spike counts for each neuron

cvx_end

if strcmpi(cvx_status,'solved')
    isfeasible = true(1,n);
else
    isfeasible = false(1,n);
end

end

function [spikes,isfeasible] = computeFeasibleSpikes_local_linprog(candidateFactorActivity,observedStats,Beta,mu)
% Simply solve the problem specified. No recursion. Just optimization.

q = size(Beta,2); % # of neurons
n = size(candidateFactorActivity,2); % # of timesteps

spikesMin = repmat(observedStats.minSpikes,1,n); % needed for assembling disciplined constraints
spikesMax = repmat(observedStats.maxSpikes,1,n); % needed for assembling disciplined constraints

% Spikes to orthonormalized factors
Brep(1:n) = {Beta};
Aeq = blkdiag(Brep{:});
beq = candidateFactorActivity(:) + repmat(Beta*mu,n,1);

LB = spikesMin(:); % Lower bound on spike counts for each neuron
UB = spikesMax(:); % Upper bound on spike counts for each neuron

[X,FVAL,EXITFLAG,OUTPUT,LAMBDA] = linprog([],[],[],Aeq,beq,LB,UB,[],optimset('Display', 'off'));

if isempty(X)
    spikes = nan(q,n); % sometimes this happens if X is infeasible
else
    spikes = reshape(X,q,n);
end

if EXITFLAG==1
    isfeasible = true(1,n);
else
    isfeasible = false(1,n);
end

end


function plotLineSearchDebug(Zstar,aStar,Pstar,Z0,Zmax,Pact,Dact,M2,m0,domainToApply)
% Use for debugging the line search. Plots progress mismatch vs alpha along
% the line search. Also shows factor values along the line search,
% dimension-by-dimension, along with their feasibility bounds.

zDim = length(Z0);
alphas = linspace(0,1,100);
Z = bsxfun(@times,(1-alphas),Z0) + bsxfun(@times,alphas,Zmax);
V = bsxfun(@plus,M2*Z,m0);

figure(99); clf;

P = V'*Dact;
subplot(1,2,1); hold on
plot(alphas,sqrt((P-Pact).^2)); 
plot(aStar,norm(Pstar-Pact),'r*');
xlabel('\alpha');
ylabel('progress mismatch');

for dimIdx = 1:zDim
    subplot(zDim,2,2*dimIdx); hold on;
    plot(alphas,Z(dimIdx,:));
    plot([0 1],[1 1]*domainToApply.maxFactors(dimIdx,:),'k--')
    plot([0 1],[1 1]*domainToApply.minFactors(dimIdx,:),'k--')
    xlabel('\alpha');
    ylabel(['z_' num2str(dimIdx)]);
end

keyboard

end