imgSet = imageSet('/home/steffen/Dokumente/KITTI/experiments/cropped_images/easy/training', 'recursive');

imgMeans = zeros(imgSet.Count,1);
for i=1:imgSet.Count
    img = imread(imgSet.ImageLocation{1,i});
    imgMeans(i,1) = mean(mean(img));
end

figure;
hist(imgMeans, 30);

figure;
img = imread(imgSet.ImageLocation{1,1106});
subplot(4,1,1);
imshow(img);
title(sprintf('mean: %0.2f', mean(mean(img))));
subplot(4,1,2);
imshow(imadjust(img, [0 0.5],[]));
subplot(4,1,3);
imshow(imadjust(img, [0.25 0.75],[]));
subplot(4,1,4);
imshow(imadjust(img, [0.5 1],[]));