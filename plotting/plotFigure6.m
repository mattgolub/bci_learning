function plotFigure6(data,hypotheses)
% @ Matt Golub, 2018.

YTICK = -200:200:600;
YLIMS = [-200 600];

xx = data.metrics.deltaPushingMagnitude;
yyReal = data.metrics.deltaVariancePercent;

dataColor = getFigureColors('data');
labels{1} = data.name;

pDLR_args = {'PLOT_DATA',false,'LINE_STYLE','-'};

%% Plot linear fits
cla; hold on;
plotDataAndLinearRegression(xx,yyReal,pDLR_args{:},'LINE_COLOR',dataColor);

for hypIdx = 1:numel(hypotheses)
    labels{hypIdx+1} = hypotheses(hypIdx).name;
    yySim(hypIdx,:) = hypotheses(hypIdx).metrics.deltaVariancePercent;
    [~,~,yHat(hypIdx,:)] = plotDataAndLinearRegression(xx,yySim(hypIdx,:),pDLR_args{:},'LINE_COLOR',getFigureColors(hypotheses(hypIdx).name));
end

%%
yyAll = [yySim(:); yyReal(:)];
xLims = getDecentAxisLims(xx);
yLims = getDecentAxisLims(yyAll);

% Include entire regression lines if it they don't stray too far
% above/below the limits of the data (managing white space)
yLimsWithLines = getDecentAxisLims([yyAll; yHat(:)]);
if range(yLimsWithLines)/range(yLims) < 1.5
    yLims = yLimsWithLines;
end

% x-ticks
xTick = getDecentTicks(xx);

%% Plot individual data points
P_data = plot(xx,yyReal,'x','color',dataColor);

for hypIdx = 1:numel(hypotheses)
    P_sim(hypIdx) = plot(xx,yySim(hypIdx,:),'o','color',getFigureColors(hypotheses(hypIdx).name));
end

%%
title('Figure 6f');
xlabel({'\Delta pushing magnitude (mm/spike)'})
ylabel('\Delta variance (%)');

L = legend([P_data P_sim],labels{:},'location','best');

set(gca,'xtick',xTick,'xlim',xLims);
set(gca,'ytick',YTICK,'ylim',YLIMS);
set(gca,'tickdir','out');

end