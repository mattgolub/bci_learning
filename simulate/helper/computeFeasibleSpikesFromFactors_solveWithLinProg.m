function [spikes,isfeasible] = computeFeasibleSpikesFromFactors_solveWithLinProg(candidateFactorActivity,observedStats,cursorParams)
% Simply solve the problem specified. No recursion. Just optimization.

[B,mu] = extractSpikesToFactorsMapping(cursorParams);
q = size(B,2); % # of neurons
n = size(candidateFactorActivity,2); % # of timesteps

spikesMin = repmat(observedStats.minSpikes,1,n); % needed for assembling disciplined constraints
spikesMax = repmat(observedStats.maxSpikes,1,n); % needed for assembling disciplined constraints
spikesMean = repmat(observedStats.meanSpikes,1,n); % needed for assembling disciplined constraints

% Spikes to orthonormalized factors
Brep(1:n) = {B};
Aeq = blkdiag(Brep{:});
beq = candidateFactorActivity(:) + repmat(B*mu,n,1);

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