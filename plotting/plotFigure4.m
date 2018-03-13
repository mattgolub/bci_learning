function plotFigure4(afterLearning,hypotheses)
% @ Matt Golub, 2018.

yTicks = -.2:.2:.4;
yLims = [-.2 .4];

metricName = 'overallRepertoireChange';

labels{1} = afterLearning.name;
values{1} = afterLearning.metrics.(metricName);
colors(1,:) = getFigureColors(afterLearning.name);

for hypIdx = 1:numel(hypotheses)
    hypothesis = hypotheses(hypIdx);
    labels{hypIdx+1} = hypothesis.name;
    values{hypIdx+1} = hypothesis.metrics.(metricName);
    colors(hypIdx+1,:) = getFigureColors(hypothesis.name);
end

boxCompareN(values,'COLORS',colors);
annotateRepertoireChangePanel(yLims,labels);

title('Figure 4b');
ylabel({'Repertoire change','(normalized)'});

set(gca,'tickdir','out');
set(gca,'xtick',1:length(labels),'xticklabel',labels,'XTickLabelRotation',45);
set(gca,'ytick',yTicks,'ylim',yLims);

end