function [Zc,Xc,nRejected] = simulateFactorsAndFiringRates(mu,Sigma,n,LI_stats,params,varargin)

ENSURE_PHYSIOLOGICAL_PLAUSIBILITY = true;
FIX_RANDOM_SEED = false;
VERBOSE = false;
assignopts(who,varargin);

nValid = 0;
nTries = 1;

nNeurons = length(LI_stats.meanSpikes);
nFactors = length(mu);

if FIX_RANDOM_SEED
    rng('default'); % Repeatable sequences from random number generators.
end

if VERBOSE
    fprintf('\t\tSimulating factor activity.\n');
end

if ENSURE_PHYSIOLOGICAL_PLAUSIBILITY
    nRejected = 0;
    Zc = nan(nFactors,n);
    Xc = nan(nNeurons,n);
    
    while nValid<n
        nRemainingToSimulate = n - nValid;
        
        if VERBOSE
            fprintf('\t\t\tAttempt %d: %d of %d patterns remain.\n',nTries,nRemainingToSimulate,n);
        end
        
        % Simulate
        Z_unchecked = mvnrnd(mu',Sigma,nRemainingToSimulate)';
        
        % For each simulated factor activity pattern, check wheter a valid
        % spike count could have produced it.
        
        [X_unchecked, isfeasible] = computeFeasibleSpikesFromFactors(Z_unchecked,LI_stats,params);
        
        nValidNew = sum(isfeasible);
        nRejected = nRejected + sum(~isfeasible);
        newValidIdx = nValid+(1:nValidNew);
        nValid = nValid + nValidNew;
        
        % Save only the feasible points from this iteration
        Zc(:,newValidIdx) = Z_unchecked(:,isfeasible);
        Xc(:,newValidIdx) = X_unchecked(:,isfeasible);
        
        nTries = nTries + 1;
    end
else
    nRejected = NaN;
    Zc = mvnrnd(mu',Sigma,n)';
    
    % Just use least-norm solution, regardless of feasibility
    [fa_beta,fa_mu] = extractSpikesToFactorMapping(params);
    pinvBeta = pinv(fa_beta);
    Xc = bsxfun(@plus,pinvBeta*Zc,fa_mu);
end