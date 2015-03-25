function [mask, result_img] = backwardWarpImg(src_img, resultToSrc_H,...
    dest_canvas_width_height)
%R,G,B channel infomation of source image
Rs = src_img(:,:,1);
Gs = src_img(:,:,2);
Bs = src_img(:,:,3);
% H * src = dest 
h = dest_canvas_width_height(1); % y ,height and width of the dest image
w = dest_canvas_width_height(2); % x

[Y,X,~] = size(src_img);

% backward find the corresponding points in the src img for the dest img

for i=1:1:w
    %create list of points of a column of dest img
    dest_pts_nx2 = [(1:h)', repmat(i,h,1)];
    % find corresponding src points
    
    src_pts_nx2 = applyHomography(resultToSrc_H, dest_pts_nx2);
    % get each R,G,B channel 
    
    XI = src_pts_nx2(:,1);
    YI = src_pts_nx2(:,2);
    
    Rd = interp2(1:X,1:Y,Rs,XI,YI);
    Gd = interp2(1:X,1:Y,Gs,XI,YI);
    Bd = interp2(1:X,1:Y,Bs,XI,YI);
    
    %SET pixel value that is outside of the cavas (NAN) to 0
    
    Rd(isnan(Rd)) = 0;
    Gd(isnan(Gd)) = 0;
    Bd(isnan(Bd)) = 0;
    %put them together
    result_img (i,:,1) = Rd;
    result_img (i,:,2) = Gd;
    result_img (i,:,3) = Bd;
end

%calculate mask , first find the four corners, needs to be in order
src_corners = [1,1 ; 1,Y; X,Y; X,1;1,1];
%find the corner coordinate in the dest img
dest_corners = applyHomography(inv(resultToSrc_H),src_corners);
mask = poly2mask(dest_corners(:,1),dest_corners(:,2),w,h);

%to change all NAN values to 0
result_img(:,:,1) = result_img(:,:,1).*im2double(mask);
result_img(:,:,2) = result_img(:,:,2).*im2double(mask);
result_img(:,:,3) = result_img(:,:,3).*im2double(mask);

end
