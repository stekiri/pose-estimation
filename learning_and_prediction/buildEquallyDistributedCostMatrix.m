function costMatrix = buildEquallyDistributedCostMatrix(numClasses, mode)
%buildEquallyDistributedCostMatrix Construct a cost matrix.
% costMatrix = buildEquallyDistributedCostMatrix(amountClasses, mode)
% constructs a cost matrix with small cost for adjacent classes and large
% costs for opposite classes. mode can be either 'linear' or 'exponential',
% numClasses contains the number of classes.

costMatrix = zeros(numClasses);

maxDistance = floor(numClasses/2);

for i=1:numClasses
    for j=1:numClasses
        helpVal = abs(i-j);
        
        if helpVal <= maxDistance
            linearCost = helpVal;
        else
            if mod(numClasses,2) == 1
                offset = 1;
            else
                offset = 0;
            end
            linearCost = helpVal - 2*(helpVal - maxDistance) + offset;
            
        end
        switch mode
            case 'exponential'
                costMatrix(i,j) = 2.^linearCost;
                for k=1:numClasses
                    costMatrix(k,k) = 0;
                end
            case 'linear'
                costMatrix(i,j) = linearCost;
        end
    end
end

end