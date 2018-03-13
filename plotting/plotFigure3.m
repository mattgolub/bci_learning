function plotFigure3(beforeLearning, afterLearning, varargin)
% @ Matt Golub, 2018.

ACTIVITY_TYPE = 'vraw_perturbed';
SHAPE_METHOD = 'convhull';
nSTDs = 2; % for plotting ellipses
FRACTION_ENCLOSED = .98;

% Center panel
CENTER.AXIS_LINE_WIDTH = 0.75;
CENTER.AXIS_LABEL_FONT_SIZE = 10;
CENTER.JOINT_LINE_WIDTH = 0.75;

% Outer (peripheral) panels
OUTER.JOINT_LINE_WIDTH = 0.25;
OUTER.CONDITIONAL_LINE_WIDTH = 0.75; % doesn't matter, swap to fill in AI
OUTER.ANNOTATE_DIRECTION = true;
OUTER.PLOT_OCTANTS = true;
OUTER.AXIS_COLOR = .5*[1 1 1];
OUTER.BOLD_AXIS_COLOR = 'k';
OUTER.AXIS_LINE_WIDTH = 0.5;
OUTER.BOLD_AXIS_LINE_WIDTH = 1;

assignopts(who,varargin);

mainPanelSize = 0.28; % on scale from 0-1
peripheralPanelSize = 0.2; % on scale from 0-1
peripheralPanelCenterScale = 0.31;

plotArgs = {'METHOD',SHAPE_METHOD,'nSTDs',nSTDs};

beforeLearning_joint = [beforeLearning.clouds.(ACTIVITY_TYPE){:}];
afterLearning_joint = [afterLearning.clouds.(ACTIVITY_TYPE){:}];

beforeLearning_conditionals = beforeLearning.clouds.(ACTIVITY_TYPE);
afterLearning_conditionals = afterLearning.clouds.(ACTIVITY_TYPE);

angles = beforeLearning.clouds.angles;
nConditions = length(angles);

% Center panel. Pre-learning data and hull. Post-learning hull only.
AX_center = subplot('position',[(1-mainPanelSize)/2 (1-mainPanelSize)/2 mainPanelSize mainPanelSize]);
hold on
switch SHAPE_METHOD
    case 'cov'
        jointShape2 = plotDataAndSummary({beforeLearning_joint},'COLOR_ORDER',[0 0 0],'PLOT_DATA',true,plotArgs{:},'LINE_WIDTH',CENTER.JOINT_LINE_WIDTH);
        jointShape3 = plotDataAndSummary({afterLearning_joint},'COLOR_ORDER',[1 0 0],'PLOT_DATA',true,plotArgs{:},'LINE_WIDTH',CENTER.JOINT_LINE_WIDTH);
    case 'convhull'
        plot(beforeLearning_joint(1,:),beforeLearning_joint(2,:),'.','color',[0 0 0])
        plot(afterLearning_joint(1,:),afterLearning_joint(2,:),'.','color',[1 0 0])
        
        [jointShape2{1},jointNonOutlierData.Y2] = plotConvexHull(beforeLearning_joint,'color',[0 0 0],'FRACTION_ENCLOSED',FRACTION_ENCLOSED,'linewidth',CENTER.JOINT_LINE_WIDTH);
        [jointShape3{1},jointNonOutlierData.Y3] = plotConvexHull(afterLearning_joint,'color',[1 0 0],'FRACTION_ENCLOSED',FRACTION_ENCLOSED,'linewidth',CENTER.JOINT_LINE_WIDTH);
        
        % Remove outliers from conditionals
        conditionalNonOutlierData.Y2 = removeOutliersFromConditionals(beforeLearning_conditionals,jointNonOutlierData.Y2);
        conditionalNonOutlierData.Y3 = removeOutliersFromConditionals(afterLearning_conditionals,jointNonOutlierData.Y3);
end
jointShapes = [jointShape2 jointShape3];

axis equal
setAxisLimsTightToEllipses(AX_center, jointShapes(:));

% To visually ensure axis equal
% plot_circle([0 0],100,'color','k');

xlims = get(gca,'xlim');
ylims = get(gca,'ylim');
r = max(xlims);

set(gca,'color','none','linewidth',CENTER.AXIS_LINE_WIDTH)
try
    % Some of these axis properties are not supported by old Matlab
    % versions (e.g., R2015a)
    set(gca,'XAxisLocation','origin','YAxisLocation','origin')
    text(r,0,'v_x','horizontalalignment','left','verticalalignment','middle','fontsize',CENTER.AXIS_LABEL_FONT_SIZE);
    text(0,r,'v_y','horizontalalignment','center','verticalalignment','bottom','fontsize',CENTER.AXIS_LABEL_FONT_SIZE);
catch
    xlabel('v_x');
    ylabel('v_y');
end

title('Figure 3');
set(gca,'xtick',[],'ytick',[])

%% Prepare radial arrangement of conditional panels
theta = linspace(0,360,nConditions+1);
unitCircle = [cosd(theta(1:nConditions)); sind(theta(1:nConditions))];
unitSquare = round(unitCircle);

alpha = 0.75;
panelCenters = ((alpha*unitCircle+(1-alpha)*unitSquare))*peripheralPanelCenterScale + 0.5;
panelBottomLeft = panelCenters - peripheralPanelSize/2;
panelTopRight = panelCenters + peripheralPanelSize/2;

% Compute expected acquisition time
if stringContainsi(ACTIVITY_TYPE,'intuitive')
    progressStr = 'intuitiveProgress';
elseif stringContainsi(ACTIVITY_TYPE,'perturbed')
    progressStr = 'perturbedProgress';
end

%% Conditionals, 1 at a time
for conditionIdx = 1:nConditions
    AX(1,conditionIdx) = subplot('position',[panelBottomLeft(:,conditionIdx)' peripheralPanelSize peripheralPanelSize]);
    hold on
    
    %% Joints
    plotDataAndSummary({beforeLearning_joint},'COLOR_ORDER',[0 0 0],'PLOT_DATA',false,'FRACTION_ENCLOSED',FRACTION_ENCLOSED,plotArgs{:},'LINE_WIDTH',OUTER.JOINT_LINE_WIDTH);
    plotDataAndSummary({afterLearning_joint},'COLOR_ORDER',[1 0 0],'PLOT_DATA',false,'FRACTION_ENCLOSED',FRACTION_ENCLOSED,plotArgs{:},'LINE_WIDTH',OUTER.JOINT_LINE_WIDTH);
    
    %% Conditionals
    switch SHAPE_METHOD
        case 'cov'
            Y2condData = beforeLearning_conditionals(conditionIdx);
            Y3condData = afterLearning_conditionals(conditionIdx);
        case 'convhull'
            Y2condData = conditionalNonOutlierData.Y2(conditionIdx);
            Y3condData = conditionalNonOutlierData.Y3(conditionIdx);
    end
    plotDataAndSummary(Y2condData,'COLOR_ORDER',[0 0 0],'PLOT_DATA',false,'FRACTION_ENCLOSED',1,plotArgs{:},'LINE_WIDTH',OUTER.CONDITIONAL_LINE_WIDTH);
    plotDataAndSummary(Y3condData,'COLOR_ORDER',[1 0 0],'PLOT_DATA',false,'FRACTION_ENCLOSED',1,plotArgs{:},'LINE_WIDTH',OUTER.CONDITIONAL_LINE_WIDTH);
    
    % Plot all after-learning data, including outliers (since they are
    % shown in center panel)
    plot(afterLearning_conditionals{conditionIdx}(1,:),afterLearning_conditionals{conditionIdx}(2,:),'.','color',[1 0 0])
    
    if OUTER.ANNOTATE_DIRECTION
        directionStr = [num2str(theta(conditionIdx)) '^o'];
        r1 = 1.2*r;
        text(r1*cosd(theta(conditionIdx)),r1*sind(theta(conditionIdx)),directionStr,...
            'horizontalalignment','center','verticalalignment','middle',...
            'fontsize',8);
    end
    
    axis equal
    
    if OUTER.PLOT_OCTANTS
        axis off
        lineEndPoints = r*unitCircle;
        arrowBase = [0 0]';
        arrowSide = r/9;
        arrowHeight = arrowSide * sqrt(3)/2;
        for i = 1:size(lineEndPoints,2)
            if i==conditionIdx
                arrowTtip = lineEndPoints(:,i);
                
                % This works and looks great, but a bit more of a headache
                % when arranging layers in AI.
                % fill_arrow(arrowBase,arrowTtip,arrowSide,arrowHeight,'linewidth',OUTER.BOLD_AXIS_LINE_WIDTH);
                
                % Easier to work with layers if adding arrowheads manually
                % in AI.
                line([0 lineEndPoints(1,i)],[0 lineEndPoints(2,i)],'color',OUTER.BOLD_AXIS_COLOR,'linewidth',OUTER.BOLD_AXIS_LINE_WIDTH);
            else
                line([0 lineEndPoints(1,i)],[0 lineEndPoints(2,i)],'color',OUTER.AXIS_COLOR,'linewidth',OUTER.AXIS_LINE_WIDTH);
            end
        end
    else
        set(gca,'XAxisLocation','origin','YAxisLocation','origin','color','none')
        set(gca,'xtick',[],'ytick',[])
    end
    setAxisLimsTightToEllipses(gca, jointShapes(:));
end

end

function [xlims, ylims] = setAxisLimsTightToEllipses(AX, ellipses)
ellipseAll = [ellipses{:}];
maxAbs = max(abs(ellipseAll(:)));
axis equal
xlims = [-maxAbs maxAbs];
ylims = [-maxAbs maxAbs];
axis(AX,[xlims ylims]);
end

function Ycond = removeOutliersFromConditionals(Ycond,Yjoint_noOutliers)
nConditions = numel(Ycond);
for conditionIdx = 1:nConditions
    K = findRowsOfAInB(Ycond{conditionIdx}',Yjoint_noOutliers');
    Ycond{conditionIdx}(:,isnan(K)) = [];
end
end