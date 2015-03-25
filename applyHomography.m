function dest_pts_nx2 = applyHomography(H_3x3, src_pts_nx2)

xs = src_pts_nx2(:,1);
ys = src_pts_nx2(:,2);

%lecture notes page16 10/2/2014
xd = ( H_3x3(1,1)*xs + H_3x3(1,2)*ys + H_3x3(1,3) ) ./ ...
    ( H_3x3(3,1)*xs + H_3x3(3,2)*ys + H_3x3(3,3) );

yd = ( H_3x3(2,1)*xs + H_3x3(2,2)*ys + H_3x3(2,3) ) ./ ...
    ( H_3x3(3,1)*xs + H_3x3(3,2)*ys + H_3x3(3,3) );

dest_pts_nx2 = [xd, yd];
end