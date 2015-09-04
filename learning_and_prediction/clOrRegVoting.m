function value = clOrRegVoting(clValue, regValue, threshold)

angleDiff = getAngleBetweenRadians(clValue, regValue);

if angleDiff <= threshold
    value = regValue;
else
    value = clValue;
end

end