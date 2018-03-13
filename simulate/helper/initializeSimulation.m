% These are the default options for realignment, rescaling, and
% reassociation. For partial realignment and subselection, set
% MATCH_PROGRESS = false.

MATCH_PROGRESS = false;
ENSURE_PHYSIOLOGICAL_PLAUSIBILITY = true;
FIX_RANDOM_SEED = false;
assignopts(who,varargin);

args = {'MATCH_PROGRESS',MATCH_PROGRESS,...
'ENSURE_PHYSIOLOGICAL_PLAUSIBILITY',ENSURE_PHYSIOLOGICAL_PLAUSIBILITY,...
'FIX_RANDOM_SEED',FIX_RANDOM_SEED};