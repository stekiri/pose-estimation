function croppedImg = cropImage(img, dimension, amountPixels)
% randomly crop picture either on the left/right or upper/lower side
ranVar = randi(2);
% dimension = 1 --> crop at upper/lower side
if dimension == 1
    if ranVar == 1
        croppedImg = img(1:(end - amountPixels), :);
    elseif ranVar == 2
        croppedImg = img((1 + amountPixels):end, :);
    end
% dimension = 2 --> crop at left/right side
elseif dimension == 2
    if ranVar == 1
        croppedImg = img(:, 1:(end - amountPixels));
    elseif ranVar == 2
        croppedImg = img(:, (1 + amountPixels):end);
    end
end

end