function simulateFcn = getSimulateFcn(hypothesisName)
% @ Matt Golub, 2018.

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
