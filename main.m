function Mosaic()
% Test image stitching

% stitch three images
imgc = im2single(imread('mountain_center.png'));
imgl = im2single(imread('mountain_left.png'));
imgr = im2single(imread('mountain_right.png'));

stitched_img = stitchImg(imgc, imgl, imgr);
figure, imshow(stitched_img);
imwrite(stitched_img, 'mountain_panorama.png');

% try 5 inputs
imgc = im2single(imread('photo 3-1.JPG'));
imgl1 = im2single(imread('photo 2-1.JPG'));
imgr1 = im2single(imread('photo 4-1.JPG'));
imgl2 = im2single(imread('photo 1-1.JPG'));
imgr2 = im2single(imread('photo 5-1.JPG'));

stitched_img2 = stitchImg(imgc, imgl1, imgr1, imgl2, imgr2);
figure, imshow(stitched_img2);
imwrite(stitched_img2, 'my_panorama_multiple.png');