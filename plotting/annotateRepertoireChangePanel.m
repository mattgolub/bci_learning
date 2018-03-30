function annotateRepertoireChangePanel(ylims,labels)
%
% @ Matt Golub, 2018.

FONTSIZE = 8;

line([0 length(labels)+1],[0 0],'linestyle','--','color','k');
text(0.1,.1*ylims(2),'Shift / Expand','horizontalalignment','left','verticalalignment','top','rotation',90,'fontsize',FONTSIZE);
text(0.1,-.1*ylims(2),'Contract','horizontalalignment','right','verticalalignment','top','rotation',90,'fontsize',FONTSIZE);
