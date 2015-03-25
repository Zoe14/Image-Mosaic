function H_3x3 = computeHomography(src_pts_nx2, dest_pts_nx2)
[r ~] = size(src_pts_nx2);
xs = src_pts_nx2(:,1);
ys = src_pts_nx2(:,2);
xd = dest_pts_nx2(:,1);
yd = dest_pts_nx2(:,2);
%create A by lecture note 10/2/2014 page 17
A = zeros(r*2, 9); %initialize
A(1:2:r*2, 1) = xs;
A(1:2:r*2, 2) = ys;
A(1:2:r*2, 3) = 1;
A(2:2:r*2, 4) = xs;
A(2:2:r*2, 5) = ys;
A(2:2:r*2, 6) = 1;
A(1:2:r*2, 7) = -xd.*xs;
A(2:2:r*2, 7) = -yd.*xs;
A(1:2:r*2, 8) = -xd.*ys;
A(2:2:r*2, 8) = -yd.*ys;
A(1:2:r*2, 9) = -xd;
A(2:2:r*2, 9) = -yd;
%compute eigenvalues and vectors of A'*A
[h,~]= eig(A'*A);
%first lamda is the smallest one,corresponding to first col of h
homo = h(:,1);
%transform to 3x3 matrix
H_3x3 = [homo(1:3)';homo(4:6)';homo(7:9)'];
end