function [inliers_id, H] = runRANSAC(Xs, Xd, ransac_n, eps)

M=0;%initialize the number of fit data points
H = zeros(3,3); %initialize hormography
inliers_id = 0;

for i=1:ransac_n
    %need at 4 points to calculate H , randomly generate 4 points 
    s = size(Xs,1); % number of data set
    rand_ind = randi(s,4,1); % generate random index number
    rand_xs = Xs (rand_ind,:); % find corresponding random Xs & Xd
    rand_xd = Xd (rand_ind,:);
    %calculate the corresponding H
    H_temp = computeHomography(rand_xs, rand_xd);
    %apply this temporary H to find all the Xd correspondign to Xs
    Xd_temp = applyHomography(H_temp,Xs);
    %calculate the euclidian distance list
    dist = ((Xd(:,1) - Xd_temp(:,1)).^2 + (Xd(:,2) - Xd_temp(:,2)).^2).^(0.5);
    %generate the list of inliners
    id = find (dist < eps);
    if length(id) > M 
        M = length(id);
        H = H_temp;
        inliers_id=id;
    end
end
end