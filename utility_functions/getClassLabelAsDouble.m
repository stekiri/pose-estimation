function classDouble = getClassLabelAsDouble(classString)

splittedString = strsplit(classString, '_');
classDouble = str2double(splittedString(1));

end