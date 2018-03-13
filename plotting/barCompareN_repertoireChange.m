function barCompareN_repertoireChange(D,varargin)
% Bar plot and pairwise comparisons across N groups of 1-D data.
% ADAPTED: NOW NOT A BAR PLOT
%
% B = barCompareN(D)
% B = barCompare(D,...)
% Additional arguments include COLOR, xx, testName, and any additional
% arguments for bar(x,y,...).
%
% D is a cell array. The data in D{i} are plotted as a bar + error bar at
% x = i.
%
% Adapted from barCompareN.m

testName = 'signtest';
PLOT_DATA = false;
MARKERWIDTH = 0.5; % for posterior mean only
LINEWIDTH = 1; % for error bar only (95% confidence interval)
PLOT_BRACKET = false;
COMPARISONS = zeros(0,2); % each row indicates a pairwise comparison
COLORS = [];
BREAK_Y_AXIS = false;
Y_BREAK = [NaN NaN];
DATA_ARE_BINARY = true;
PRINT_P_VALUES = false;
rem = assignopts(who,varargin);

hold on;

N = numel(D);
for xx = 1:N
    D{xx} = D{xx}>0;
    if DATA_ARE_BINARY
        [m(xx) l(xx) u(xx)] = bernoulliPost(D{xx}(:));
        m(xx) = transformToNegativeOneToOne(m(xx));
        u(xx) = transformToNegativeOneToOne(u(xx));
        l(xx) = transformToNegativeOneToOne(l(xx));
    else
        [m(xx),sem(xx), n(xx)] = meanAndSEM(D{xx});
        l(xx) = m(xx)-sem(xx);
        u(xx) = m(xx)+sem(xx);
    end
    
    if isempty(COLORS)
        color = 'k';
    else
        color = COLORS(xx,:);
    end
    
    if PLOT_DATA
        if BREAK_Y_AXIS
            [yy,idxWithinYBreak] = plotOnBrokenAxes_adjustDataForBreak(D{xx}(:),Y_BREAK);
        else
            yy = D{xx}(:);
        end
        plot(xx*ones(length(yy),1),yy,'o','color',color);
    end
    
    if BREAK_Y_AXIS
        [mPlot(xx),idxWithinYBreak] = plotOnBrokenAxes_adjustDataForBreak(m(xx),Y_BREAK);
        if isnan(mPlot(xx))
            lPlot(xx) = nan;
            uPlot(xx) = nan;
        else
            lPlot(xx) = l(xx);
            uPlot(xx) = u(xx);
        end
        if m(xx)>Y_BREAK(2)
            % Annotate bar height if above break.
            % Conceivably, one might want this reversed: annotate if below break
            text(xx,mPlot(xx),sprintf('%.2f',m(xx)),'horizontalalignment','left');
        end
    else
        mPlot(xx) = m(xx);
        uPlot = u;
        lPlot = l;
    end
    % Used this through NN revisions
    % plot(xx,mPlot(xx),'s','color',color,'linewidth',LINEWIDTH);
    line(xx+MARKERWIDTH*[-1 1]/2,mPlot(xx)*[1 1],'color',color,'linewidth',LINEWIDTH);
    
    % Errorbar with no top/bottom brackets (width of those is hard to
    % standardize across different sized figures
    line([xx xx],[l(xx) u(xx)],'color',color,'linewidth',LINEWIDTH);
end

scale = 0.075;
yyMaxPlot = max(uPlot);
yyMinPlot = min(lPlot);
yyRange = yyMaxPlot-yyMinPlot;
yLims = [min(0,yyMinPlot-scale*yyRange) yyMaxPlot+scale*yyRange];
ylim(yLims);

if ~isempty(rem)
    set(B,rem{:});
end

if BREAK_Y_AXIS
    plotOnBrokenAxes_plotBreakAnnotation(Y_BREAK,'y')
end
xlim([0 N+1]);

if ~isempty(COMPARISONS)
    
    % Significance annotations furthest away from each other (horizontally) get the highe annotations (vertically).
    vertSep = max(mPlot+sem)/15; % vertical distance between annotations
    nComparisons = size(COMPARISONS,1);
    annotationLengths = COMPARISONS(:,2)-COMPARISONS(:,1);
    [~,sortIdx] = sort(annotationLengths,'ascend');
    
    COMPARISONS = COMPARISONS(sortIdx,:);
    for compareIdx = 1:nComparisons
        idx1 = COMPARISONS(compareIdx,1);
        idx2 = COMPARISONS(compareIdx,2);
        
        p = hypothesisTestHelper(D{idx1}(:),D{idx2}(:),testName);
        
        if PRINT_P_VALUES
            fprintf('p=%.3e, n1=%d, n2=%d.\n',p,numel(D{idx1}),numel(D{idx2}));
        end
        
        xxAnnotation = [idx1 idx2];
        yyAnnotation = yyMaxPlot + compareIdx*vertSep;
        bracketHeight = vertSep;
        
        if isempty(COLORS)
            color = 'k';
        else
            color = COLORS(idx2,:);
        end
        
        bar_significance(xxAnnotation, yyAnnotation, bracketHeight, p,...
            'color',color,'PLOT_BRACKET_ENDS', false, 'ANNOTATION_LOCATION','left');
    end
    
end
end

function y = transformToNegativeOneToOne(x)
y = 2*x - 1;
end