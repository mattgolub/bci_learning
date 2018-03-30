function [simL, subselectionStats] = matchProgressViaSubselection(preL,perturbedMapping,LI_clouds,LP_clouds,varargin)
% @ Matt Golub, 2018.

numConditions = length(preL.P_conditionAveraged);
actual_LP = extractActualLearningActivity(LP_clouds);

for cIdx = 1:numConditions
    fprintf('\t\tMovement-specific cloud %d: ',cIdx);
    
    idx = find(preL.C==cIdx);
    N = length(idx);
    
    Pstar = actual_LP.P_conditionAveraged(cIdx);
    Ppre = preL.P_conditionAveraged(cIdx); % same as mean(preL.P(idx))
    
    if Pstar>Ppre
        % drop patterns to increase progress
        [sortedProgress, idxSort] = sort(preL.P(idx),'descend');
        increaseOrDecreaseStr = 'INCREASE';
    else
        % drop patterns to decrease progress
        [sortedProgress, idxSort] = sort(preL.P(idx),'ascend');
        increaseOrDecreaseStr = 'DECREASE';
    end
    
    avgDroppedProgress = cumsum(sortedProgress)./(1:N);
    [~,nAccept] = min(abs(avgDroppedProgress-Pstar));
    idxAccept = idx(idxSort(1:nAccept));
    
    C_accept{cIdx} = preL.C(idxAccept);
    P_accept{cIdx} = preL.P(idxAccept);
    D_accept{cIdx} = preL.D(:,idxAccept);
    V_accept{cIdx} = preL.V(:,idxAccept);
    Z_accept{cIdx} = preL.Z(:,idxAccept);
    X_accept{cIdx} = preL.X(:,idxAccept);
    
    Zp.mean(:,cIdx) = mean(Z_accept{cIdx},2);
    Zp.cov(:,:,cIdx) = cov(Z_accept{cIdx}',1);
    
    percentDropped = 100*(N-nAccept)/N;
    
    subselectionStats.nAccept(cIdx) = nAccept; % # Patterns kept from the pre-learning sample
    subselectionStats.nDrop(cIdx) = N-nAccept; % # Patterns dropped from the pre-learning sample
    subselectionStats.Pstar(cIdx) = Pstar; % Empirical average progress from the LP patterns
    subselectionStats.Ppre(cIdx) = Ppre; % Average progress from the pre-learning sample (i.e., before dropping patterns)
    
    fprintf('dropped %.0f%% of patterns to %s progress.\n',percentDropped,increaseOrDecreaseStr);
end

simAccept.C = [C_accept{:}];
simAccept.D = [D_accept{:}];
simAccept.P = [P_accept{:}];
simAccept.V = [V_accept{:}];
simAccept.Z = [Z_accept{:}];
simAccept.X = [X_accept{:}];

fprintf('\tResampling patterns to equalize conditional counts.\n');
[simResampled, subselectionStats.nRejectedResampling] = generateFromConditionalClouds(LI_clouds,LP_clouds,perturbedMapping,Zp,subselectionStats.nDrop,varargin{:});

simL = mergeSimulatedData(simAccept, simResampled);