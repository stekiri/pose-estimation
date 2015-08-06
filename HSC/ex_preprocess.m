imgLoc = '/home/steffen/Dokumente/KITTI/experiments/cropped_images/easy/training/Car_0.03_000002913_0_0.00.png';
imgLoc = '/home/steffen/Dokumente/KITTI/experiments/cropped_images/easy/training/Car_0.07_000003386_0_0.00.png';
imgLoc = '/home/steffen/Dokumente/KITTI/experiments/cropped_images/easy/training/Car_0.09_000000108_0_0.00.png';
imgLoc = '/home/steffen/Dokumente/KITTI/experiments/cropped_images/easy/training/Car_0.09_000000720_0_0.00.png';



img = imread(imgLoc);
imgAdj = imadjust(img);
imgAdj2 = imadjust(img, [0.25 0.75],[]);
imgAdj3 = imadjust(img, [0 0.5],[]);

figure;
subplot(4,1,1);
imagesc(img); colormap('gray');
subplot(4,1,2);
imagesc(imgAdj); colormap('gray');
subplot(4,1,3);
imagesc(imgAdj2); colormap('gray');
subplot(4,1,4);
imagesc(imgAdj3); colormap('gray');

figure;
imshow(imgLoc);
imcontrast;


img3 = whiten(double(img)/255);

mX = bsxfun(@minus,img,mean(mean(img))); %remove mean
fX = fft(fft(mX,[],2),[],3); %fourier transform of the images
spectr = sqrt(mean(abs(fX).^2)); %Mean spectrum
wX = ifft(ifft(bsxfun(@times,fX,1./spectr),[],2),[],3); %whitened X

patchSize = [8 8];
imgSize = size(img);

% extract patches
X=im2col(img,patchSize,'sliding');

imgRecon = col2im(X, patchSize, imgSize, 'distinct');
% whitening?
X=X-repmat(mean(X),[size(X,1) 1]);
% normalization
X=X ./ repmat(sqrt(sum(X.^2)),[size(X,1) 1])





B = reshape(double(1:25),[5 5])'
X = im2col(B,[2 5])
Xm=X-repmat(mean(X),[size(X,1) 1]);


A = col2im(C,[10 1],[5 5],'distinct')