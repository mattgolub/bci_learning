function simulateFcn = getSimulateFcn(hypothesisName)

switch lower(hypothesisName)
    case 'realignment'
        simulateFcn = @simulateRealignment;
    case 'rescaling'
        simulateFcn = @simulateRescaling;
    case 'reassociation'
        simulateFcn = @simulateReassociation;
    case 'partial realignment'
        simulateFcn = @simulatePartialRealignment;
    case 'subselection'
        simulateFcn = @simulateSubselection;
    otherwise
        error('Unsupported hypothesis: %s',hypothesisName);
end

end
