specResult = allResults{1,1};



%% Visualization: differences for all predictions
ar = {ar_iwv, ar_iwv};
% ar = {ar_standMaj, ar_wv, ar_iwv, ar_special, ar_special_weight};
titles = {'majority vote', 'weighted voting', 'inverse weighted voting', ...
    'specialized voting', 'specialized voting and weights'};

allDiffs = cell(1,length(ar));
for j=1:length(ar)
    for i=1:10
        allDiffs{1,j} = [allDiffs{1,j}; ar{1,j}{1,1}.cvResults{1,i}.results{1,3}];
    end
end

badBound = 2;
for j=1:length(ar)
    sum(allDiffs{1,j} > badBound)
end

bins = 40;
yLimits = [0 2000];

for j=1:length(ar)
    diffVec = allDiffs{1,j};
    
    figure;
    histogram(diffVec, bins)
    
    evalMetric = 1/size(diffVec, 1) * sum(arrayfun(@(x) (1+cos(x))/2, diffVec));
    tanhMetric = 1/size(diffVec, 1) * sum(arrayfun(@(x) (1-tanh(x)), diffVec));
    
    title({titles{1,j};...
        sprintf('cos-metric: %0.6f', evalMetric);...
        sprintf('tanh-metric: %0.6f', tanhMetric)})
    ylim(yLimits)
end