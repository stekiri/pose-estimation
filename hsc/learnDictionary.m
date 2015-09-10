function [D, model] = learnDictionary(imgSet, imgParams, spamsParams)
%learnDictionary Learn a dictionary of patches.
% [D, model] = learnDictionary(imgSet, imgParams, spamsParams) returns a
% dictionary D which contains all the most frequently used patches in an
% image set. The SPAMS library is used for this purpose.

tic
fprintf('Learn dictionary ... ');

% create backup directory to save snapshots
dateTime = fix(clock);
timeStamp = sprintf('%04d_%02d_%02d-%02d_%02d_%02d', dateTime);
backupDir = fullfile('/home/steffen/Dropbox/Aktuelles_Semester/Masterarbeit/Matlab_files/SC_experiments', timeStamp);
mkdir(backupDir);

% learn initial model
X = computeUniformPatches(imgSet(1,1).ImageLocation{1,1}, imgParams);
[D, model] = mexTrainDL(X,spamsParams);

reverseStr = '';
amountClasses = size(imgSet,2);
for i=1:amountClasses
    for j=1:imgSet(1,i).Count

        param2=spamsParams;
        param2.D=D;
        X = computeUniformPatches(imgSet(1,i).ImageLocation{1,j}, imgParams);
        [D, model] = mexTrainDL(X,param2,model);
        
    end
    % save after learning from one class of the imageSet
    fileName = sprintf('dict+model_after_class_%02d.mat', i);
    save(fullfile(backupDir, fileName), 'D', 'model');
    
    % display progress
    msg = sprintf('%d/%d', i, amountClasses);
    fprintf([reverseStr, msg]);
    reverseStr = repmat(sprintf('\b'), 1, length(msg));
end
t = toc;
fprintf(' ... computation time: %f\n',t);

end
