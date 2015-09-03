%% load image

imgLocation = '/home/steffen/Dokumente/KITTI/experiments/classified_images/easy_cl16_mir150_rem150/training/01_-2.75/Car_-2.56_-00003064_0_0.03.png';
% new location (not flipped):
newLocation = '/home/steffen/Dokumente/KITTI/experiments/classified_images/cv_easy_rgb_cl16/fold_04/07_-0.39/Car_-0.58_000002852_0_0.03.png';
img = imread(newLocation);
img = rgb2gray(img);
img = fliplr(img);

img = imread(imgLocation);
% crop image to fit grid later
img = img(1:157,1:421);

%% One histogram for complete image
[hog1, vis1] = extractHOGFeatures(img,'CellSize',[size(img,1) size(img,2)], ...
    'BlockSize', [1 1]);

figure;
imshow(imgLocation);
subplot(2,1,1);
imshow(img);
subplot(2,1,2);
bar(hog1)
set(gca, 'yticklabel', [])

%% Multiple histograms
amountPatches = [4 6];
cellSize = [floor(size(img,1)/amountPatches(1)) floor(size(img,2)/amountPatches(2))];

[hogMult, visMult] = extractHOGFeatures(img,'CellSize',cellSize, 'BlockSize', [1 1]);

% both in one
figure;
subplot(2,1,1);
imshow(img); hold on;
plot(visMult)
subplot(2,1,2);
bar(hogMult)


hogReshaped = reshape(hogMult, [9 amountPatches(1)*amountPatches(2)]);

figure;
for i=1:(amountPatches(1)*amountPatches(2))
    subplot(amountPatches(1), amountPatches(2), i);
    bar(hogReshaped(:,i), 'black');
    set(gca, 'xticklabel', [])
    set(gca, 'yticklabel', [])
end

%% paint grid over car
figure;
imgRGB = cat(3, img, img, img);
colorValue = [255, 0, 0];
for i=1:3
    imgRGB(1:cellSize(1):end,:,i) = colorValue(i);
    imgRGB(:,1:cellSize(2):end,i) = colorValue(i);
end
a = imgRGB(:,2:3,1);
imshow(imgRGB);
imwrite(imgRGB, 'car_with_red_grid.png');

%% extract one cell
singleCell = imgRGB(41:78,72:140,:);
figure;
imshow(singleCell)

%% stripes
lineStrength = 10;
imgSize = [500 500];
black = uint8(repmat(0, 1, lineStrength));
white = uint8(repmat(255, 1, lineStrength));
stripesImg = repmat([black'; white'], imgSize(1)/(lineStrength*2), imgSize(2));

[hogStripes, visStripes] = extractHOGFeatures(stripesImg,'CellSize',[500 500], ...
    'BlockSize', [1 1], 'NumBins', 9);

figure; imshow(stripesImg);

% artificial bar plot for stripes image
barVal = [0 0 0 0 1 0 0 0 0];
figure;
bar(barVal, 'black');
set(gca, 'yticklabel', [])
ylim([0 1.2])

%% mirror images

imgLowClass = imread(trainingSets(1,11).ImageLocation{1,8});
imgMirrorClass = imread(trainingSets(1,13).ImageLocation{1,1});
mirroredImg = fliplr(imgMirrorClass);

imwrite(imgLowClass, 'imgLowClass.png');
imwrite(imgMirrorClass, 'imgMirrorClass.png');
imwrite(mirroredImg, 'mirroredImage.png');
