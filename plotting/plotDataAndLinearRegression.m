function [p,B,yHat] = plotDataAndLinearRegression(X, Y, varargin)
% X is a data matrix with observations as rows. A column of ones will be
% appended if not already there (to determine bias term), unless
% ZERO_OFFSET == true;
% Y is a column vector of outputs
%
% @ Matt Golub, 2018.

LINE_COLOR = 'k';
LINE_STYLE = []; % default to '-' for p<.05, '--' otherwise
DATA_COLOR = 'k';
DATA_MARKER = 'x';
PLOT_DATA = true;
ZERO_OFFSET = false;
ANNOTATE_P_VALUE = false;
assignopts(who,varargin);

X = X(:);
Y = Y(:);

if ZERO_OFFSET && (isempty(X) || isempty(Y))
    p = nan;
    B = nan;
    return;
elseif ~ZERO_OFFSET && (length(X)<=1 || length(Y)<=1)
    p = nan;
    B = [nan nan];
    return;
end

validXrows = ~any(isnan(X),2);
validY = ~isnan(Y);
valid = validXrows & validY;

X = X(valid,:);
Y = Y(valid);

[n,d] = size(X);

% Append column of ones
if ~ZERO_OFFSET && ~(all(X(:,d)==1))
    X = [X ones(n,1)];
end

% z-score covariates if more than 1 in case you want to interpret the
% regression weights
if d>1 % d is number of covariates (ie columns before appending ones)
    X(:,1:d) = zscore(X(:,1:d),1,1);
end

[B,BINT,R,RINT,STATS] = regress(Y,X);

p = STATS(3);
if isempty(LINE_STYLE)
    if p<0.05
        LINE_STYLE = '-';
    else
        LINE_STYLE = '--';
    end
end

isHold = ishold;
if ~isHold
    hold on
end

if size(X,2)<=2
    xx = [min(X(:,1)) max(X(:,1))];
    if ZERO_OFFSET
        yHat = xx*B(1);
    else
        yHat = xx*B(1) + B(2);
    end
    if PLOT_DATA
        plot(X(:,1),Y,DATA_MARKER,'color',DATA_COLOR); % plot raw data
    end
    L = plot(xx,yHat,'color',LINE_COLOR,'linestyle',LINE_STYLE); % plot best-fit line
    if ANNOTATE_P_VALUE
        legend(L,sprintf('p=%s',printPValue(p)),'location','best');
    end
else
    yHat = X*B;
    if PLOT_DATA
        plot(Y,yHat,DATA_MARKER,'color','k'); % plot predicted vs actual data
    end
    maxY = max([yHat;Y]);
    minY = min([yHat;Y]);
    plot([minY maxY],[minY maxY],'k--') % plot unity line
end

if ~isHold
    hold off;
end

end