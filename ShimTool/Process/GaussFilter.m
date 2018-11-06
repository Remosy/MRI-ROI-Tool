function [B1p,B1pGauss] = GaussFilter(ImagSig,mask_shm, channel)
%GAUSSFILTER Summary of this function goes here
%   ImagSig: Current image with current channel
% Gaussian Filter of B1
% Check mask size
if numel(size(ImagSig))>=3
    B1p = ImagSig.*repmat(mask_shm, [1,1,1,channel]);
else 
    B1p = ImagSig.*repmat(mask_shm, [1,1,channel]);
end

B1pGauss = zeros(size(B1p));
radius = 5;
sigma = 0.5;
h = fspecial('gaussian', [radius, radius], sigma);
B1p_temp = reshape(B1p, size(B1p,1), size(B1p,2),[]);

for ii = 1:size(B1p_temp,3)
    B1pGauss(:,:,ii) = imfilter((B1p(:,:,ii)), h);
end
B1pGauss = reshape(B1pGauss, size(B1p));
