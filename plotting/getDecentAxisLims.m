function lims = getDecentAxisLims(x,limitScale)
% lims = getDecentAxisLims(x)
% lims = getDecentAxisLims(x,limitsScale)
%       limitScale: 2D vector specifying range extension at lower and upper
%       limits of the data, respectively.
%
% @ Matt Golub, 2018.

if nargin==1
    limitScale = [0.025 0.025];
end

minx = min(x(:));
maxx = max(x(:));
rangex = maxx-minx;

lims(1) = (minx - limitScale(1)*rangex);
lims(2) = (maxx + limitScale(2)*rangex);

% Avoid incrementing range on lower below zero if no data are below 0
if minx>=0 && lims(1)<0
    lims(1) = 0;
end

% arbitrarily include zero if there is no range
if lims(1)==lims(2)
    if lims(1)>0
        lims(1) = 0;
    elseif lims(1)<0
        lims(2) = 0;
    else
        % both are 0. arbitrarily set to [0 1] so ylim doesn't throw error.
        lims = [0 1];
    end
end