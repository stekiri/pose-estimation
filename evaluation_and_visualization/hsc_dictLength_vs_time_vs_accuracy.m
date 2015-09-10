% script to create the figure with dictionary lenght vs computation time
% vs accuracy for the HSC features

% extracted from result objects in result folder
dictLengths     = [25       64      100     256];
cosMetrics      = [0.955    0.964   0.964   0.965];
tanhMetrics     = [0.841    0.850   0.851   0.853];
compTime        = [4.7      9.9     16.8    59.9]; % in minutes
cValues         = [0.5      1       0.25    0.5];

%% Draw plot

% set plot parameter
yLimitsMetric = [0.9, 1];
yLimitsTime = [0, 80];
tickDistanceMetric = 0.02;
tickDistanceTime = 10;


figure;
[ax,p1,p2] = plotyy(dictLengths, cosMetrics, dictLengths, compTime);
ylabel(ax(1),'cosine metric') % label left y-axis
ylabel(ax(2),'computation time [min]') % label right y-axis
xlabel('dictionary length') % label x-axis

% write values into plot
for i=1:length(dictLengths)
    text(dictLengths(i), 0.995*cosMetrics(i), sprintf('%0.3f',cosMetrics(i)),'HorizontalAlignment','center')
end

ax(1).YLim = yLimitsMetric;
ax(2).YLim = yLimitsTime;

set(ax, 'XGrid', 'on')
set(ax, 'XTick', dictLengths)

set(ax(1), 'YTick', ax(1).YLim(1):tickDistanceMetric:ax(1).YLim(2))
set(ax(2), 'YTick', ax(2).YLim(1):tickDistanceTime:ax(2).YLim(2))

% switch left box off to remove ticks on right y-axis
set(ax(1),'box','off')

p1.Marker = 'd';
p2.Marker = 's';

% p1.MarkerEdgeColor = 'black';
% p2.MarkerEdgeColor = 'black';

p1.LineStyle = '--';
p2.LineStyle = '--';

p1.LineWidth = 2;
p2.LineWidth = 2;

% draw upper line in plot manually
