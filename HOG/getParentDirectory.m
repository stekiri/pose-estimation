function parentDir = getParentDirectory(path, depth)

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