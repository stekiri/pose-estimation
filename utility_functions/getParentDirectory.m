function parentDir = getParentDirectory(path, depth)
%getParentDirectory Get the parent directory.
% Recursive determination of the parent directory by defining a depth
% larger than 1.

pathSplit = strsplit(path, '/');
parentDirSplit = pathSplit(1, 1:end-1);
parentDirTemp = '';
for i = 1:length(parentDirSplit)
    parentDirTemp = strcat(parentDirTemp, parentDirSplit{1, i}, '/');
end
% remove last '/' symbol
parentDirTemp = parentDirTemp(1:end-1);
if depth == 1
    parentDir = parentDirTemp;
else
    parentDir = getParentDirectory(parentDirTemp, depth-1);
end

end