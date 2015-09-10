function folderNames = getSubfolders(directory)
%getSubfolders Get the names of the subfolders.
% Returns the names of all subfolders from a specific directory

listing = dir(directory);
subFolders = [listing(:).isdir]; % get only folders
folderNames = {listing(subFolders).name}'; % get all folder names
folderNames(ismember(folderNames,{'.','..'})) = []; % remove '.' and '..' folders

end
