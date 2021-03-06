function bin = getBinAssignment(deviation, numBins)
%getBinAssignment Compute to which bin a deviation belongs to.
% For the computation of the error plot, it is necessary to know to which
% bin a certain deviation belongs to.

deviationLimits = linspace(0,3.14,numBins+1);
deviationBins = zeros(numBins,2);

for i=1:numBins
    
    lowerLimit = deviationLimits(i);
    upperLimit = deviationLimits(i+1);
    
    deviationBins(i,:) = [lowerLimit, upperLimit];
end

for j = 1:numBins
    if deviation >= 3.14
        bin = numBins;
        break;
    elseif deviation >= deviationBins(j, 1) && deviation < deviationBins(j, 2)
        bin = j;
        break;
    end
end

end