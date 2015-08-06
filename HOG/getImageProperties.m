function [type, angle, number, occlusion, truncation, height, width] = ...
    getImageProperties(imagePath)

[~, fileName, ~] = fileparts(imagePath);

properties = strsplit(fileName, '_');

type       = properties{1};
angle      = str2double(properties{2});
number     = str2double(properties{3});
occlusion  = str2double(properties{4});
truncation = str2double(properties{5});

img = imread(imagePath);
height = size(img,1);
width = size(img,2);

end