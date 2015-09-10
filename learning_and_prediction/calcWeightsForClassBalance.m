function classWeights = calcWeightsForClassBalance(imgsPerClass, factor)
%calcWeightsForClassBalance Calculate weights to ensure class balance.
% classWeights = calcWeightsForClassBalance(imgsPerClass, factor) returns
% weights which can improve the problem that results when classes are
% imbalanced. Without weights small classes are less likely to be predicted
% and large classes are over-represented.

classWeights = [];

% calc weights for classes depending on their size
maxImgs = max(imgsPerClass);
classWeights = zeros(1,length(imgsPerClass));
for c=1:length(imgsPerClass)
    classWeights(1,c) = factor * maxImgs / imgsPerClass(1,c);
end

end