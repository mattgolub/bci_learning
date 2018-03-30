% simulateRealignment_constrainMarginalDomains
%
% Use within CVX problems in the simulateRealignment framework to constrain
% factor activity and firing rates to be within the marginal domains
% defined by the signal means from late intuitive trials.
%
% Constructed as a script rather than a function so that it can be easily
% invoked within and replicated across CVX problems.
%
% Called by: 
%       simulateRealignment_findMaxProgressFactors
%       simulateRealignment_findMatchedProgressFactors::solveHelper
%
% @ Matt Golub, 2018.

% number of points being optimized
% findMaxProgressFactors: # of conditions
% findMatchedProgressFactors: 1
nOpt = size(Zstar,2); 

variable Xstar(nNeurons,nOpt) % post-learning pseudo spike counts

marginalSignalDomains = computeMarginalSignalDomains(LI_stats);

% Upper / lower bounds on spike counts
% This corresponds to Eq. 26 in the Supp Math Note
Zstar == Beta*(Xstar - repmat(mu,1,nOpt))

% Spikes are physiologically plausible
% These correspond to Eq. 25 in the Supp Math Note
repmat(marginalSignalDomains.minSpikes,1,nOpt) <= Xstar 
Xstar <= repmat(marginalSignalDomains.maxSpikes,1,nOpt)