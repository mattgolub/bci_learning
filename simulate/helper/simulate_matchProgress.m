function [Zp, stats] = simulate_matchProgress(Zp_maxProgress,LI_clouds,LP_clouds,cursorParams,MATCH_PROGRESS)

numConditions = size(Zp_maxProgress.mean,2);

if MATCH_PROGRESS
    % Interpolate between LI and max-progress conditional means to match
    % observed progress
    [Zp, stats] = simulate_findMatchedProgressFactors(Zp_maxProgress,LI_clouds,LP_clouds,cursorParams);
else
    Zp = Zp_maxProgress;
    stats.alpha = ones(1,numConditions);
    stats.progressGap = nan(1,numConditions);
end