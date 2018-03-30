function color = getFigureColors(labelStr)
% labelStr is 'data' or some flavor of reassociate, realign, restore, etc
%
% @ Matt Golub, 2018.

% Results from get(gca,'colorOrder'); % MATLAB R2015a
colorOrder = [0    0.4470    0.7410
    0.8500    0.3250    0.0980
    0.9290    0.6940    0.1250
    0.4940    0.1840    0.5560
    0.4660    0.6740    0.1880
    0.3010    0.7450    0.9330
    0.6350    0.0780    0.1840];

if stringContainsi(labelStr,'data') || stringContainsi(labelStr,'mapping')
    color = [0 0 0]; % black
elseif stringContainsi(labelStr,'reassociate') || stringContainsi(labelStr,'reassociation')
    color = colorOrder(1,:); % blue
elseif stringContainsi(labelStr,'realign') || stringContainsi(labelStr,'realignment')
    color = colorOrder(2,:); % red/orange
elseif stringContainsi(labelStr,'restore') || stringContainsi(labelStr,'rescale') || stringContainsi(labelStr,'rescaling') 
    color = colorOrder(3,:); % yellow
elseif stringContainsi(labelStr,'pruning') || stringContainsi(labelStr,'subselect') || stringContainsi(labelStr,'subselection')  
    color = colorOrder(6,:); % light blue (because pruning is most related to reassociation)
else color = [.7 .7 .7]; % default color for unrecognized labelStr
end
