function plotFigure7(afterLearning,hypotheses)
% @ Matt Golub, 2018.

XX_beforeLearningAnnotation = 1.5;
XX_afterLearningAnnotation = 5;
XX_beforeAfterSplit = 2.5;
YY_annotation = 3.75;

YTICKS = 0:4;
YLIMS = [0 4];

labels{1} = 'Intuitive mapping';
values{1} = afterLearning.metrics.predictedAcqTime_beforeLearningIntuitive;
colors(1,:) = getFigureColors(afterLearning.name);

labels{2} = 'Perturbed mapping';
values{2} = afterLearning.metrics.predictedAcqTime_beforeLearningPerturbed;
colors(2,:) = getFigureColors(afterLearning.name);

labels{3} = 'Perturbed mapping';
values{3} = afterLearning.metrics.predictedAcqTime_afterLearningPerturbed;
colors(3,:) = getFigureColors(afterLearning.name);

for hypIdx = 1:numel(hypotheses)
    hypothesis = hypotheses(hypIdx);
    labels{hypIdx+3} = hypothesis.name;
    values{hypIdx+3} = hypothesis.metrics.predictedAcqTime_afterLearningPerturbed;
    colors(hypIdx+3,:) = getFigureColors(hypothesis.name);
end

boxCompareN(values,'COLORS',colors);
line([1 1]*XX_beforeAfterSplit,YLIMS,'linestyle','--','color','k');

title('Figure 7');
ylabel('Acquisition time (s)');

text(XX_beforeLearningAnnotation,YY_annotation,{'Before','learning'},'horizontalalignment','center','verticalalignment','top');
text(XX_afterLearningAnnotation,YY_annotation,{'After','learning'},'horizontalalignment','center','verticalalignment','top');

set(gca,'xtick',1:length(labels),'xticklabel',labels,'XTickLabelRotation',45);
set(gca,'ytick',YTICKS);
set(gca,'tickdir','out');
ylim(YLIMS);

end