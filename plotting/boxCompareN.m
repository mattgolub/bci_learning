function boxCompareN(D,varargin)
% Box plot and pairwise comparisons across N groups of 1-D data.
%
% B = barCompareN(D)
% B = barCompare(D,...)
% Additional arguments include COLOR, xx, testName, and any additional
% arguments for bar(x,y,...).
%
% D is a cell array. The data in D{i} are plotted as a bar + error bar at
% x = i.
%
% Adapted from barCompare.m

testName = 'signrank';
COMPARISONS = [];  % each row indicates a pairwise comparison
COLORS = [];
assignopts(who,varargin);

hold on;

K = numel(D);
N = numel(D{1});
dataMatrix = nan(N,K);
if isempty(COLORS)
    COLORS = zeros(K,3);
end
for xx = 1:K
    [m(xx),sem(xx)] = meanAndSEM(D{xx});
    if ~isempty(D{xx})
        dataMatrix(:,xx) = D{xx}(:);
    else
        dataMatrix(:,xx) = nan;
    end
    fillColor = COLORS(xx,:) + (1-COLORS(xx,:))/2;
    
    plotBox(xx,D{xx},'EDGE_COLOR',COLORS(xx,:),'FILL_COLOR',fillColor);
end

% boxplot(dataMatrix,'colors',COLORS,'symbol','o');

yyMaxPlot = max(dataMatrix(:));

xlim([0 K+1]);

if ~isempty(COMPARISONS)
    
    % Significance annotations furthest away from each other (horizontally) get the highe annotations (vertically).
    vertSep = max(m+sem)/15; % vertical distance between annotations
    nComparisons = size(COMPARISONS,1);
    annotationLengths = COMPARISONS(:,2)-COMPARISONS(:,1);
    [~,sortIdx] = sort(annotationLengths,'ascend');
    
    COMPARISONS = COMPARISONS(sortIdx,:);
    for compareIdx = 1:nComparisons
        idx1 = COMPARISONS(compareIdx,1);
        idx2 = COMPARISONS(compareIdx,2);
        
        p = hypothesisTestHelper(D{idx1},D{idx2},testName);

        xxAnnotation = [idx1 idx2];
        yyAnnotation = yyMaxPlot + compareIdx*vertSep;
        bracketHeight = vertSep;
        
        bar_significance(xxAnnotation, yyAnnotation, bracketHeight, p,...
            'PLOT_BRACKET_ENDS', false, 'ANNOTATION_LOCATION','left','color',COLORS(idx2,:));
    end
    ylims = getDecentAxisLims(dataMatrix);
    ylims(2) = yyAnnotation + vertSep;
    ylim(ylims);
end