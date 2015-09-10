function classDouble = getClassLabelAsDouble(classString)
%getClassLabelAsDouble Convert class label to a double.

splittedString = strsplit(classString, '_');
classDouble = str2double(splittedString(1));

end