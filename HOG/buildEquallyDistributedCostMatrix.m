function costMatrix = buildEquallyDistributedCostMatrix(amountClasses, mode)

costMatrix = zeros(amountClasses);

maxDistance = floor(amountClasses/2);

for i=1:amountClasses
    for j=1:amountClasses
        helpVal = abs(i-j);
        
        if helpVal <= maxDistance
            linearCost = helpVal;
        else
            if mod(amountClasses,2) == 1
                offset = 1;
            else
                offset = 0;
            end
            linearCost = helpVal - 2*(helpVal - maxDistance) + offset;
            
        end
        switch mode
            case 'exponential'
                costMatrix(i,j) = 2.^linearCost;
                for k=1:amountClasses
                    costMatrix(k,k) = 0;
                end
            case 'linear'
                costMatrix(i,j) = linearCost;
        end
    end
end

end