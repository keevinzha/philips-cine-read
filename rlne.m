function R=rlne(im_ori,im_rec)
%% evaluation the reconstruction error with relative L2 norm error
%% Xiaobo Qu
%% Xiamen University
%% April 16,2011
imError=im_ori-im_rec;
R=norm(imError(:),2)./norm(im_ori(:),2);