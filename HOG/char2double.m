function doubleArray = char2double(charArray)
% conversion of labels from char to double

amountLabels = size(charArray, 1);
% initialize
doubleArray = zeros(amountLabels, 1);

for i = 1:amountLabels
    splittedLabel = strsplit(charArray(i,:), '_');
    doubleArray(i, 1) = str2double(splittedLabel{2});
end

end