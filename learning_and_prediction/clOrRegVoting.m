function value = clOrRegVoting(clValue, regValue, threshold)
%clOrRegVoting Decide between classification or regression.
% value = clOrRegVoting(clValue, regValue, threshold) returns the value
% which should be used. If the deviation between the regression and the
% the classification is larger than a certain threshold, the
% classification estimate is used otherwise the regression estimate.

deviation = getAngleBetweenRadians(clValue, regValue);

if deviation <= threshold
    value = regValue;
else
    value = clValue;
end

end