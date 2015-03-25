function stitched_img = stitchImg(varargin)
   % assume the input order is center, left, right, left, right.....
   % assume input number is 3*N
   imgC = im2double(varargin{1});
   for i=2:1:nargin-1
    %after blending, keep updating center img, left img and right img
    imgL = varargin{i};
    imgR = varargin{i+1}; 
    imgC = DoStitch(imgC,imgL,imgR);
    %repeat
   end
      stitched_img = imgC;
end

function result = DoStitch(imgC,imgL,imgR)
    %find SIFT interest point
    [xCL,xL] = genSIFTMatches(imgC,imgL);
    [xCR,xR] = genSIFTMatches(imgC,imgR);
    %do ransac to eliminate outliners, and find homography
    ransac_n = max(length(xL),length(xR))/2;
    ransac_eps = 1;
    %center image is destination, H maps left img to center
    [~,H_LC] = runRANSAC(xL, xCL, ransac_n, ransac_eps);
    %center image is destination, H maps right img to center
    [~,H_RC] = runRANSAC(xR, xCR, ransac_n, ransac_eps);
    %compute the bounds of source image in reference image
    %M is y, N is x
    [ML, NL, ~] = size(imgL);
    [MR, NR, ~] = size(imgR);
    Left_bounds = [1,1;NL,1;NL,ML;1,ML];
    Right_bounds = [1,1;NR,1;NR,MR;1,MR];
    Lref_bounds = applyHomography(H_LC,Left_bounds);
    Rref_bounds = applyHomography(H_RC,Right_bounds);
    %the result may have negative position,
    %get the offset; n for negative, p for positive
    Loffset_x = round(min(Lref_bounds(:,1)));
    Loffset_yn = round(min(Lref_bounds(:,2)));
    Loffset_yp = round(max(Lref_bounds(:,2)));
    
    Roffset_x = round(max(Rref_bounds(:,1)));
    Roffset_yn = round(min(Rref_bounds(:,2)));
    Roffset_yp = round(max(Rref_bounds(:,2)));
    
    offset_yn = min(Loffset_yn,Roffset_yn);
    offset_yp = max(Loffset_yp,Roffset_yp);
    %expand the reference image frame to fit
    img_ref = imgC;
    %append offset_x zeros to the left reference image
    if (Loffset_x < 0) 
        img_ref = [zeros(size(imgC,1), -Loffset_x, 3) img_ref];
    end
    if (Roffset_x > size(imgC,2)) 
        img_ref = [img_ref, zeros(size(imgC,1), Roffset_x-size(imgC,2), 3) ];
    end
    %append offset_yn amount of zeros to the top of reference image
    if (offset_yn < 0 ) 
        img_ref= [zeros(-offset_yn, size(img_ref,2), 3); img_ref];
    end
    %append offset_yp amount of zeros to the bottom of reference image
    if (offset_yp > size(imgC,1)) 
        img_ref= [img_ref;zeros(offset_yp-size(imgC,1), size(img_ref,2), 3)];
    end
    %get a new H for transform btwn img_ref and imgL,imgR
    [xrefL,xL] = genSIFTMatches(img_ref,imgL);
    [xrefR,xR] = genSIFTMatches(img_ref,imgR);
    %center image is destination, H maps left img to center
    [~,H_Lref] = runRANSAC(xL, xrefL, ransac_n, ransac_eps);
    %center image is destination, H maps right img to center
    [~,H_Rref] = runRANSAC(xR, xrefR, ransac_n, ransac_eps);  
    %within bounds, compute each pixel's location in reference image
    dest_wh = [size(img_ref, 2), size(img_ref, 1)];
    %maskL indicate where the warped left img is on the ref img 
    [maskL, left_img]=backwardWarpImg(imgL,inv(H_Lref),dest_wh);
    maskL(isnan(maskL))=0;
    %maskR indicate where the warped left img is on the ref img
    [maskR, right_img]=backwardWarpImg(imgR,inv(H_Rref),dest_wh);
    maskR(isnan(maskR))=0;
    %maskC indicate where the center img is on the ref img,
    %create maskC
    maskC = ones(size(imgC(:,:,1)));
    if (Loffset_x < 0) 
        maskC = [zeros(size(imgC,1), -Loffset_x) maskC];
    end
    if (Roffset_x > size(imgC,2))
        maskC = [maskC, zeros(size(imgC,1), Roffset_x-size(imgC,2))];
    end
    if (offset_yn < 0) 
        maskC = [zeros(-offset_yn, size(maskC,2)); maskC];
    end
    if (offset_yp > size(imgC,1) )
        maskC= [maskC;zeros(offset_yp-size(imgC,1), size(maskC,2))];
    end
    %blend images,left to ref then right to ref
    maskCL = maskC + maskL; %mask for blended left half image
    maskCL (maskCL > 0) = 1; %make it binary
    maskCL(isnan(maskCL))=0; 
    result1 = blendImagePair(left_img, maskL, img_ref, maskC,'blend');
    result1 (isnan(result1))=0; %set nan pixel to 0
    result = blendImagePair(right_img, maskR, result1, maskCL,'blend');
    result (isnan(result))=0;
end