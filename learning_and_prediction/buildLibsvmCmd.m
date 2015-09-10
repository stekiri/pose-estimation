function cmd = buildLibsvmCmd(params, addPar)
%buildLibsvmCmd Builds the command for the libsvm library.
% cmd = buildLibsvmCmd(params, addPar) builds the command which is used to
% execute the libsvm library. params contains all the settings, addPar only
% has to be specified for a specific experiment with specialized
% classifiers and can be ommited in general.

% general settings:
% -q    quiet mode
% -s 0  C-SVM classification
cmd = '-q -s 0 -t ';

% set kernel
switch params.kernel
    case 'linear'
        cmd = [cmd, '0'];
    case 'polynomial'
        cmd = [cmd, '1'];
    case 'rbf'
        cmd = [cmd, '2'];
end

% set svm options
if ~strcmp(params.svmParameter.C, '-')
    cmd = [cmd, ' -c ', num2str(params.svmParameter.C)];
end

if any(strcmp(params.kernel, {'polynomial', 'rbf'}))
    if ~strcmp(params.svmParameter.gamma, '-')
        cmd = [cmd, ' -g ', num2str(params.svmParameter.gamma)];
    end
end

% set weights for imbalanced classes
if strcmp(params.weights, 'automaticWeights')
    classWeights = calcWeightsForClassBalance(params.imgsPerClass, params.weightFactor);
    if nargin > 1 && strcmp(params.voting, 'specialized')
        
        specClassWeights = zeros(1, length(classWeights));
%         specClassWeights(1,addPar.i) = addPar.factor;
%         specClassWeights(1,addPar.j) = 1;
        specClassWeights(1,addPar.i) = classWeights(1,addPar.i) * addPar.factor;
        specClassWeights(1,addPar.j) = classWeights(1,addPar.j) * 1;
        
        classWeights = specClassWeights;
    end
    weightCmd = [];
    for c=1:length(classWeights)
        weightCmd = [weightCmd, '-w', num2str(c), ' ', num2str(classWeights(1,c)), ' '];
    end
    cmd = [cmd, ' ', weightCmd];
end

% compute probabilities if desired
if params.computeProbs
    cmd = [cmd, ' ', '-b 1'];
end

end