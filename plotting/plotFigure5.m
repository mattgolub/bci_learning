function plotFigure5(data,hypotheses)
% @ Matt Golub, 2018.

cla; hold on;
h = plotHelper(data);
labels{1} = data.name;

for hypIdx = 1:numel(hypotheses)
    hypothesis = hypotheses(hypIdx);
    h(hypIdx+1) = plotHelper(hypothesis);
    labels{hypIdx+1} = hypothesis.name;
end

title('Figure 5c');
xlabel({'\Delta covariability along','intuitive mapping (%)'});
ylabel({'\Delta covariability along','perturbed mapping (%)'});

L = legend(h,labels{:},'location','best');

set(gca,'tickdir','out');

end

function h = plotHelper(S)

h = plot(S.metrics.deltaVarIntuitive,S.metrics.deltaVarPerturbed,'o','color',getFigureColors(S.name));

end
