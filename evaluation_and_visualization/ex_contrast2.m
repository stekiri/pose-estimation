
imgLocation = worstLocs{6,1};
[path, imgName, ext] = fileparts(imgLocation);


img = imread(imgLocation);

figure;
imshow(img)
imcontrast;

mean(mean(img))
var(double(im2col(img, [1 1],'distinct')))

imgAdj1 = imadjust(img, [0.25 0.75],[]);
imgAdj2 = imadjust(img, [0.2 0.65],[]);
imgAdj3 = imadjust(img, [0.5 1],[]);

figure;
subplot(4,1,1);
imshow(img);
subplot(4,1,2);
imshow(imgAdj1);
subplot(4,1,3);
imshow(imgAdj2);
subplot(4,1,4);
imshow(imgAdj3);

imgPrepro = imadjust(img, [0 0.65],[]);

backupLoc = '/home/steffen/Schreibtisch/backup_imgs';
copyfile(imgLocation, fullfile(backupLoc, strcat(imgName, ext)));

imwrite(imgPrepro, imgLocation);


imgEnl = imresize(img, 2);
figure;
imshow(img);

%% blabla

position = find(strcmp(imgLocation, worstLocs));
