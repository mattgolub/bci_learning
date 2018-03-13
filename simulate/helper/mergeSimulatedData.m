function simMerged = mergeSimulatedData(sim1, sim2)

n = size(sim1.Z,2);

fnames = fieldnames(sim1);
for fIdx = 1:numel(fnames)
    fname = fnames{fIdx};
    if size(sim1.(fname),2)==n
        simMerged.(fname) = [sim1.(fname) sim2.(fname)];
    end
end
simMerged.P_conditionAveraged = computeConditionAveragedProgress(simMerged);
