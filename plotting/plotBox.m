function plotBox(x,Y,varargin)
% Provides customized box plotting, one box at a time.
%
% x is a scalar
% Y is a vector or matrix of data

Y = Y(:);

BOX_UPPER_PCTL = 75;
BOX_LOWER_PCTL = 25;

WHISKER_UPPER_PCTL = 95;
WHISKER_LOWER_PCTL = 5;

BOX_WIDTH = 0.8;

FILL_COLOR = 'none';
EDGE_COLOR = 'k';

PLOT_DATA = false;
PLOT_OUTLIERS = false;
MARKER = '.';
MARKERSIZE = 5;

MEDIAN_LINEWIDTH = 1;
BOX_LINEWIDTH = 0.75;
WHISKER_LINEWIDTH = 0.5;

% Arbitrary choices, but seems to work well
JITTER_DELTA_Y = (max(Y)-min(Y))/10; % Defines a window about each y-value
JITTER_N_MAX = 10; % Jitter has maximum variance when this many or more y-values fall into window centered at a given y-value

assignopts(who,varargin);

if isempty(Y) || all(isnan(Y))
    return
end

holdStatus = ishold();
hold on;

xxBox = x + BOX_WIDTH*[-.5 .5];

pctl = [WHISKER_LOWER_PCTL BOX_LOWER_PCTL 50 BOX_UPPER_PCTL WHISKER_UPPER_PCTL];
yy_pctl = percentile(Y(:),pctl);

yyWhiskerBottom = yy_pctl(1);
yyBoxBottom = yy_pctl(2);
yyMedian = yy_pctl(3);
yyBoxTop = yy_pctl(4);
yyWhiskerTop = yy_pctl(5);
 
% Box
if ~isequal(FILL_COLOR,'none')
    fill(xxBox([1 1 2 2]),[yyBoxBottom yyBoxTop yyBoxTop yyBoxBottom],FILL_COLOR);
end
line(xxBox([1 1 2 2 1]),[yyBoxBottom yyBoxTop yyBoxTop yyBoxBottom yyBoxBottom],'color',EDGE_COLOR,'linewidth',BOX_LINEWIDTH);

% Median
line(xxBox,yyMedian*[1 1],'COLOR',EDGE_COLOR,'linewidth',MEDIAN_LINEWIDTH);

% Whiskers
line([x x],[yyBoxTop yyWhiskerTop],'color',EDGE_COLOR,'linewidth',WHISKER_LINEWIDTH);
line([x x],[yyBoxBottom yyWhiskerBottom],'color',EDGE_COLOR,'linewidth',WHISKER_LINEWIDTH);

% Data
if PLOT_DATA
    xxJitter = jitterXVals2(x,Y,BOX_WIDTH,JITTER_DELTA_Y);
    plot(xxJitter,Y,'color',EDGE_COLOR','marker',MARKER,'markersize',MARKERSIZE,'linestyle','none');
elseif PLOT_OUTLIERS
    yyOutliers = Y(Y<yyWhiskerBottom | Y>yyWhiskerTop);
    xxJitter = jitterXVals2(x,yyOutliers,BOX_WIDTH,JITTER_DELTA_Y);
    plot(xxJitter,yyOutliers,'color',EDGE_COLOR','marker',MARKER,'markersize',MARKERSIZE,'linestyle','none');
end

if ~holdStatus
    hold off
end

end

function xJitter = jitterXVals1(x,Y,boxWidth)
% All xJitter values are drawn from the same distribtuion, a truncated
% normal.

% Start with a normal distribution with mean-x and sigma=boxWidth/6
normalDist = makedist('Normal','mu',x,'sigma',boxWidth/6);

% Truncate so jitter values beyond box width are never generated
truncNormalDist = truncate(normalDist,x-boxWidth/2,x+boxWidth/2);

xJitter = random(truncNormalDist,size(Y));

end

function xJitter = jitterXVals2(x,Y,boxWidth,deltaY)
% Determine jitter to apply to x-values so that x-values are close to x,
% but can be further away as y-value concentration increases (i.e., to
% minimize overlap, and to give a better sense of the distribution of
% points).

% Jitter variance will saturate at a reasonable maximum if there are this
% many points within deltaY of a given y
nMaxSigma = 10; 

xJitter = nan(size(Y));

for yIdx = 1:length(Y)
    % Count number of y's within deltaY of Y(yIdx)
    n = sum(abs(Y-Y(yIdx))<deltaY);
    
    % Arbitrary mapping:
    if n==1
        xJitter(yIdx) = x;
    else
        % scale is between 0 and 1, and increases linearly with n until
        % reaching (nMaxSigma+1), at which point it saturates at 1.
        scale = min((n-1)/nMaxSigma,1);
        
        
        % Start with a normal distribution with mean-x and sigma=boxWidth/6
        normalDist = makedist('Normal','mu',x,'sigma',scale*boxWidth/6);
        
        % Truncate so jitter values beyond box width are never generated
        truncNormalDist = truncate(normalDist,x-boxWidth/2,x+boxWidth/2);
        
        xJitter(yIdx) = random(truncNormalDist);
    end
end

end