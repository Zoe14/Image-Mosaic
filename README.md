# Image-Mosaic
Developed an "Image Mosaicing App" that stiches a collection of photos into a mosaic / panaromic picture. Used SIFT algorithm to generate interest points and RANSAC algorithm to eliminate outliers, eventually applied homograph matrix to stitch images together. Some important functions will be explained below:  
##compute Homography:  
separate x,y coordinate for both source and destination points. then create matrix A described in lecture.Compute eigen values and vectors of A’*A use matlab function eig. The result will contains multiple sets of solutions. Select the eigenvector that is corresponding to the smallest eigenvalue, which is the first one. Transform that vector to a 3x3 matrix to get 3x3 homograph matrix.  
##applyHomography:  
Given the homograph matrix and points in the source image, to compute the corresponding points in the destination image.
Using the information in lecture notes page16, the x,y coordinates can be computed.  
##backwardWarpImg:  
First separate the source image into R,G,B channel. Then backward find the corresponding points in the source image of each pixel in the destination image. To let it be more efficient, it is processed column by column. The mask is got by using the corner coordinate in the destination image, which is computed by applying homograph to the corner coordinates of the source image.  
##runRANSAC:  
Randomly generate 4 index number, and find the corresponding Xs, Xd samples. Calculate the corresponding homographs model using this set of samples. Calculate the number of data points that fit the model within error, using euclidian distance. Repeat this process rancac_n times, choose the model has most incliners.  
##blendImagePair:  
First check what is the input mode.
For overlay mode, simply superimpose the image using the mask information.
For blend mode, use bwdist to create weighted mask then get the weighted images. Then superimpose two weighted images.  
##stitchImg:  
Here are two assumptions I have for this function:
1. the input order is center image, first left image next to the center, first right image next to the center, second left image next to the center, second right image next to the center……   
2. the number of input is 3*N where N = 1,2,3…   
The solution for various number of input is:  
blend the first three images and then use it as the center image, blend it with the next left, right images.  
A function called DoStitch takes three inputs and stitch center, left, right image together. The algorithm for this function:  
1. Find SIFT interest points between left and center images, and right and center images, using provided function genSIFTMatches 
2. Use RANSAC to eliminate outliners and find homographs for two sets of SIFT interest points generated in step 1  
3. Compute the bounds of left and right images in the reference image (center image). Using the size information of the images, apply homograph to find the bounds.   
4. The results in step 3 will be out of bounds of original center image. Add padding to the center image to create the reference frame.  
5. Get two new homograph matrixes between left image and reference frame,  right image and reference frame, using genSIFTMatches and runRANSAC.  
6. Use backwardWarpingImg to compute the warped left image and warped right image and their corresponding mask (indicate where the warped images is in the reference frame  
7. Calculate the mask for the center image in the reference frame, using the padding information in step 4  
8. Blend left image and center image,using blendImagePair and the mask information  
9. Blend right image and the left half image get from step 8 to get the final result. Notice the mask for left half image is the sum of left image mask and center image mask. And to get the correct image, need to make sure all the NAN values are set to 0.  

### Some test result can be found in the repository
