function shapes = plotDataAndSummary(X,varargin)
% Helper function for:
%   plotDataAndCovariance
%   plotDataAndConvHull

METHOD = 'cov'; % 'cov','convhull','both','none'
COLOR_ORDER = get(gca,'colorOrder');
COLOR_START_IDX = 1; % used to be:
 % COLOR_START_IDX = get(gca,'colorOrderIndex'); % THIS WAS SCREWING UP COLORS IN compareJointsAndConditionals_plotClouds
LINE_STYLE = '-';
LINE_WIDTH = 2;
PLOT_DATA = true;
MARKER_SIZE = 6; % 6 is the MATLAB default.
nSTDs = 1; % for plotting ellipses
FRACTION_ENCLOSED = .95; % for plotting convex hulls
assignopts(who,varargin);

isHold = ishold();
if ~isHold
    cla;
    hold on;
end

nColors = size(COLOR_ORDER,1);
nConditions = numel(X);
shapes = cell(1,nConditions);

if PLOT_DATA
    for conditionIdx = 1:nConditions
        Xi = X{conditionIdx};
        
        % Cycle gracefully through colors
        colorIdx = COLOR_START_IDX + conditionIdx - 1;
        if mod(colorIdx,nColors)==0
            C = COLOR_ORDER(nColors,:);
        else C = COLOR_ORDER(mod(colorIdx,size(COLOR_ORDER,1)),:);
        end
        
        plot(Xi(1,:),Xi(2,:),'.','color',C,'MarkerSize',MARKER_SIZE);
    end
end

for conditionIdx = 1:nConditions
    Xi = X{conditionIdx};
    [mu, Sigma] = meanAndCov(Xi);
    
    % Cycle gracefully through colors
    colorIdx = COLOR_START_IDX + conditionIdx - 1;
    if mod(colorIdx,nColors)==0
        C = COLOR_ORDER(nColors,:);
    else C = COLOR_ORDER(mod(colorIdx,size(COLOR_ORDER,1)),:);
    end
    
    plotArgs = {'linewidth',LINE_WIDTH,'color',C,'linestyle',LINE_STYLE};
    switch METHOD
        case 'cov'
            shapes{conditionIdx} = plotCovarianceEllipse(mu,Sigma,'nSTDs',nSTDs,plotArgs{:});
            plotCovarianceEllipse(mu,Sigma,'nSTDs',.1,plotArgs{:}); % PLOT MEAN
        case 'convhull'
            [shapes{conditionIdx},Xi_enclosed,Xi_outliers] = plotConvexHull(Xi,'FRACTION_ENCLOSED',FRACTION_ENCLOSED,plotArgs{:});
        case 'both'
            shape1 = plotCovarianceEllipse(mu,Sigma,'nSTDs',nSTDs,plotArgs{:});
            plotCovarianceEllipse(mu,Sigma,'nSTDs',.1,plotArgs{:}); % PLOT MEAN
            shape2 = plotConvexHull(Xi,'FRACTION_ENCLOSED',FRACTION_ENCLOSED,plotArgs{:});
            shapes{conditionIdx} = [shape1 shape2];
        case 'none'
            shapes{conditionIdx} = zeros(2,0);
        otherwise
            error('Unsupported method: %s',METHOD);
    end
end

% Always include full shapess in the axis limits
shapesAll = cell2mat(shapes);
maxDataPlotX = max(shapesAll(1,:));
minDataPlotX = min(shapesAll(1,:));
maxDataPlotY = max(shapesAll(2,:));
minDataPlotY = min(shapesAll(2,:));

if PLOT_DATA
    % Set axis limits to middle 98% of the data
    minPctl = 0;
    maxPctl = 100;
    d_all = cell2mat(X);
    maxDataPlotX = max(maxDataPlotX,percentile(d_all(1,:),maxPctl));
    minDataPlotX = min(minDataPlotX,percentile(d_all(1,:),minPctl));
    maxDataPlotY = max(maxDataPlotY,percentile(d_all(2,:),maxPctl));
    minDataPlotY = min(minDataPlotY,percentile(d_all(2,:),minPctl));
    shapes{nConditions+1} = [minDataPlotX maxDataPlotX; minDataPlotY maxDataPlotY];
end


% axis image
% box off
% axis off
set(gca,'tickDir','out');
axis equal
axis([minDataPlotX maxDataPlotX minDataPlotY maxDataPlotY]);


if ~isHold
    hold off;
end

end