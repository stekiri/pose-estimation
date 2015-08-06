function folderNames = getSubfolders(imgDir)

listing = dir(imgDir);
subFolders = [listing(:).isdir]; % get only folders
folderNames = {listing(subFolders).name}'; % get all folder names
folderNames(ismember(folderNames,{'.','..'})) = []; % remove '.' and '..' folders

end