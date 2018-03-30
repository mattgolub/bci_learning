function [spikes, isfeasible] = computeFeasibleSpikesFromFactors(candidateFactorActivity,observedStats,cursorParams,varargin)
% Determine whether a valid point in the joint firing rate space (of
% neurons) could have resulted in candidate factor activity values.
%
% @ Matt Golub, 2018.

% This amounts to solving a linear program, which can be done for a single
% activity pattern, or jointly across a set of patterns. This poses an
% inherent tradeoff on compute time: solving once over a set of patterns is
% faster than solving iteratively for each pattern; however, if solving
% over a set of patterns, infeasibility makes it difficult to know which
% patterns could not satisfy the constraints--in that case the set of
% patterns must be subdivided to determine which patterns are feasible and
% which are not.

% For my typical problem (100 patterns, 10 factors, 100 neurons), the
% 'recursive' solution is about 4x faster than the 'iterative' one. Using
% 'linprog' is about 10x faster than using 'cvx' using both of their
% default solvers.

% Note, this could be done while jointly optimizing factor activities, but
% that tends to be very slow due to the high-dimensionality of the neuron
% space. Presumably, constraining factors to be within observed marginal
% ranges does most of the heavy lifting in constraining simulated patterns
% to be neurophysiologically plausible. Use this to reject any simulated
% factor patterns that exceed the limits of observed spike counts.

% It may be possible to re-run the factors optimization (possibly even
% warm-start) adding in only a few extra constraints for the few infeasible
% spike counts.

METHOD = 'recursive'; % 'recursive' or 'iterative'
SOLVER = 'linprog'; % 'linprog' is much faster than 'cvx'
VERBOSE = false;
assignopts(who,varargin);

n = size(candidateFactorActivity,2); % # of timesteps

switch METHOD
    case 'recursive'
        % Solve recursively by splitting set of patterns in half until sets
        % contain 10 or fewer patterns, then solve. If infeasible, split
        % set again...
        [spikes,isfeasible] = divideAndConquer(candidateFactorActivity,observedStats,cursorParams,SOLVER);
        if VERBOSE
            fprintf('\t\t\t%d passed; %d failed.\n',sum(isfeasible),sum(~isfeasible));
        end
    case 'iterative'
        % Solve iteratively, brute force
        for i = 1:n
            [spikes(:,i),isfeasible(:,i)] = divideAndConquer(candidateFactorActivity(:,i),observedStats,cursorParams,SOLVER);
            if VERBOSE
                fprintf('\t\t\t%d passed; %d failed.\n',sum(isfeasible),sum(~isfeasible));
            end
        end
end

end

function [spikes,isfeasible] = divideAndConquer(candidateFactorActivity,observedStats,cursorParams,SOLVER)

VERBOSE = false;

MAX_N = 10; % break down problem into sequential problems of this size or smaller
n = size(candidateFactorActivity,2); % # of timesteps

if n>MAX_N
    idx1 = randperm(n,floor(n/2));
    idx2 = setdiff(1:n,idx1);
    
    [spikes(:,idx1), isfeasible(idx1)] = divideAndConquer(candidateFactorActivity(:,idx1),observedStats,cursorParams,SOLVER);
    [spikes(:,idx2), isfeasible(idx2)] = divideAndConquer(candidateFactorActivity(:,idx2),observedStats,cursorParams,SOLVER);
else
    % Attempt to solve problem
    if VERBOSE
        fprintf('\t\t\t\tSolving feasibility problem (n=%d)...',n);
    end
    
    switch SOLVER
        case 'cvx'
            [spikes, isfeasible] = computeFeasibleSpikesFromFactors_solveWithCVX(candidateFactorActivity,observedStats,cursorParams);
        case 'linprog'
            [spikes, isfeasible] = computeFeasibleSpikesFromFactors_solveWithLinProg(candidateFactorActivity,observedStats,cursorParams);
    end
    
    % If failed, but for n>1, break down into small problems and try again
    if n==1 || all(isfeasible)
        if VERBOSE
            fprintf('passed.\n');
        end
        return
    else
        idx1 = randperm(n,floor(n/2));
        idx2 = setdiff(1:n,idx1);
        
        if VERBOSE
            fprintf('failed, splitting [%d,%d].\n',length(idx1),length(idx2));
        end
        
        [spikes(:,idx1), isfeasible(idx1)] = divideAndConquer(candidateFactorActivity(:,idx1),observedStats,cursorParams,SOLVER);
        [spikes(:,idx2), isfeasible(idx2)] = divideAndConquer(candidateFactorActivity(:,idx2),observedStats,cursorParams,SOLVER);
    end
end
end