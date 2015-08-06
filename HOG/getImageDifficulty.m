function [diffStr, diffNumber] = getImageDifficulty(occlusion, truncation, height)

if     occlusion == 0 && truncation <= 0.15 && height >= 40
    diffStr     = 'easy';
    diffNumber  = 1;
elseif occlusion <= 1 && truncation <= 0.30 && height >= 25
    diffStr     = 'moderate';
    diffNumber  = 2;
elseif occlusion <= 2 && truncation <= 0.50 && height >= 25
    diffStr     = 'hard';
    diffNumber  = 3;
end

end