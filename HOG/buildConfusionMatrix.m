function confMat = buildConfusionMatrix(truthLabels, predictedLabels, amountClasses)

confMat = zeros(amountClasses);

for i=1:amountClasses
    for j=1:amountClasses
        confMat(i,j) = sum(truthLabels == i & predictedLabels == j);
    end
end

end