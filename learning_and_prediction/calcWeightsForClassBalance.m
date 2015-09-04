function classWeights = calcWeightsForClassBalance(imgsPerClass, factor)

classWeights = [];

% calc weights for classes depending on their size
maxImgs = max(imgsPerClass);
classWeights = zeros(1,length(imgsPerClass));
for c=1:length(imgsPerClass)
    classWeights(1,c) = factor * maxImgs / imgsPerClass(1,c);
end

end