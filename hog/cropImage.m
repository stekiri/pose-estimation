function croppedImg = cropImage(img, dimension, amountPixels)
%cropImage Crop a row or column of a picture.
% croppedImg = cropImage(img, dimension, amountPixels) crops a row or a
% column of a picture. Columns are cut away either from the left or the
% right side. Rows are cut away randomly either from the upper or lower
% side.

ranVar = randi(2);
% crop at upper/lower side
if dimension == 1
    if ranVar == 1
        croppedImg = img(1:(end - amountPixels), :);
    elseif ranVar == 2
        croppedImg = img((1 + amountPixels):end, :);
    end
% crop at left/right side
elseif dimension == 2
    if ranVar == 1
        croppedImg = img(:, 1:(end - amountPixels));
    elseif ranVar == 2
        croppedImg = img(:, (1 + amountPixels):end);
    end
end

end
