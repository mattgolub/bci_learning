function plotFigure8(afterLearning, hypotheses)
% @ Matt Golub, 2018.

yLims = [-1 1];
yTicks = [-1 0 1];
yTickLabels = [100 0 100];

labels{1} = afterLearning.name;
values{1} = afterLearning.metrics.movementSpecificRepertoireChange;
colors(1,:) = getFigureColors(afterLearning.name);

for hypIdx = 1:numel(hypotheses)
    hypothesis = hypotheses(hypIdx);
    labels{hypIdx+1} = hypothesis.name;
    values{hypIdx+1} = hypothesis.metrics.movementSpecificRepertoireChange;
    colors(hypIdx+1,:) = getFigureColors(hypothesis.name);
end

barCompareN_repertoireChange(values,'COLORS',colors);

annotateRepertoireChangePanel(yLims,labels);

title('Figure 8c');
ylabel({'% of movements showing','movement-specific repertoire change'});

set(gca,'xtick',1:length(labels),'xticklabel',labels,'XTickLabelRotation',45);
set(gca,'ytick',yTicks,'ylim',yLims,'yticklabel',yTickLabels);
set(gca,'tickdir','out');

end