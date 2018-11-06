close all;
clc;
clear
%%
% read B1 maps from dicom images
% Signal Images
MagSig = [];
for ii = 1:8    % phase magnitude
    fstring = ['1\',num2str(ii),'.IMA'];
    MagSig = cat(3, MagSig, double(dicomread(fstring)));
end
PhaSig = [];
for ii = 9:16    % signal phase
    fstring = ['1\', num2str(ii), '.IMA'];
    pha = double(dicomread(fstring));
    PhaSig = cat(3, PhaSig, (( pha-(2048-1800) )./(1800*2).*(2.*pi)) - pi );
end
ImagSig = MagSig.*exp(1i.*PhaSig);
figure; subplot(1,2,1); imshow3(abs(ImagSig)); subplot(1,2,2); imshow3(angle(ImagSig));

% manually define anatomical region
figure; mask_ana = roipoly(abs(ImagSig(:,:,1))./max(max(abs(ImagSig(:,:,1)))));
figure; imshow(mask_ana);
% load mask_ana
gyro = 42.58*1e6*2*pi;
B1p = ImagSig.*repmat(mask_ana, [1,1,8]);

% Gaussian Filter of B1
B1pGauss = zeros(size(B1p));
radius = 5;
sigma = 0.5;
h = fspecial('gaussian', [radius, radius], sigma);
for ii = 1:8
    B1pGauss(:,:,ii) = imfilter((B1p(:,:,ii)), h);
end
figure; 
subplot(2,1,1); imshow3(abs(B1pGauss),[], [1,8]);
subplot(2,1,2); imshow3(angle(B1pGauss),[], [1,8]);

% manually define region of interest for shim calculation
figure; mask_shm = roipoly(abs(B1pGauss(:,:,1))./max(max(abs(B1pGauss(:,:,1)))));
% mask_shm = zeros(size(mask_ana));
% mask_shm(61-37:61+37, :) = 1;  mask_shm = mask_shm>eps;
% mask_shm = mask_shm & mask_ana;
figure; imshow(mask_shm)
mask_zero = mask_ana & ~mask_shm;
figure; imshow(mask_zero)

% Shims 1 & 2
A = zeros(numel(find(mask_shm))+numel(find(mask_zero)), 8);
B = zeros(numel(find(mask_shm)), 8);
A_all = reshape(B1p, [], 8);

for ii = 1:8
    temp = B1pGauss(:,:,ii);
    A(:, ii) = [temp(mask_shm); temp(mask_zero)];
    B(:, ii) = temp(mask_shm);
end
B1target = 1e-6;    % 1 uT
shim1 = pinv(A)*(B1target.*[ones(numel(find(mask_shm)),1); zeros(numel(find(mask_zero)),1)]); % focused shim
shim2 = pinv(B)*(B1target.*ones(numel(find(mask_shm)),1));  % shim within ROI

B1p_shim1 = reshape(A_all*shim1, size(mask_shm));
figure; 
subplot(1,2,1); imshow(abs(B1p_shim1),[]); colormap jet; hold on;
subplot(1,2,2); imshow(angle(B1p_shim1),[]); colormap jet; hold on; 
title('Shimming focused');

B1p_shim2 = reshape(A_all*shim2, size(mask_shm));
figure; 
subplot(1,2,1); imshow(abs(B1p_shim2),[]); colormap jet; hold on; 
subplot(1,2,2); imshow(angle(B1p_shim2),[]); colormap jet; hold on; 
title('Shimming within ROI');

% shims 3 & 4: magnitude least square shim
[shim3, difMLS, TotalIter] = myMLS(A, B1target.*[ones(numel(find(mask_shm)),1); zeros(numel(find(mask_zero)),1)].*exp(1i.*pi/2), 0.01, 1000);
[shim4, difMLS, TotalIter] = myMLS(B, B1target.*ones(numel(find(mask_shm)),1).*exp(1i.*pi/2), 0.01, 1000);

B1p_shim3 = reshape(A_all*shim3, size(mask_shm));
figure; 
subplot(1,2,1); imshow(abs(B1p_shim3),[]); colormap jet; hold on; 
subplot(1,2,2); imshow(angle(B1p_shim3),[]); colormap jet; hold on; 
title('MLS focused');

B1p_shim4 = reshape(A_all*shim4, size(mask_shm));
figure; 
subplot(1,2,1); imshow(abs(B1p_shim4),[]); colormap jet; hold on; 
subplot(1,2,2); imshow(angle(B1p_shim4),[]); colormap jet; hold on; 
title('MLS shimming within ROI');

% calculating the inhomogeneity of shimmed B1 within ROI
difff = abs(B1p_shim3(mask_shm)) - mean(abs(B1p_shim3(mask_shm)));
sqrt(mean(difff.^2))./mean(abs(B1p_shim3(mask_shm)))

difff = abs(B1p_shim4(mask_shm)) - mean(abs(B1p_shim4(mask_shm)));
sqrt(mean(difff.^2))./mean(abs(B1p_shim4(mask_shm)))

% shim5: phase-only shim within ROI
AvgPha = zeros(8, 1);
for ii = 1:8
    temp = B1pGauss(:,:,ii);
    AvgPha(ii) = angle(mean(temp(mask_shm)));
end

shim5 = exp(-1i.*AvgPha)*max(abs(shim3));
B1p_shim5 = reshape(A_all*shim5, size(mask_shm));
figure; 
subplot(1,2,1); imshow(abs(B1p_shim5),[]); colormap jet; hold on; 
subplot(1,2,2); imshow(angle(B1p_shim5),[]); colormap jet; hold on; 
title('Phase only ROI');

[abs(shim3)./max(abs(shim3)),angle(shim3)*180/pi]
figure; polarplot([0 pi/4 pi/2 3*pi/4 pi 5/4*pi, 3/2*pi, 7/4*pi], abs(shim3)./max(abs(shim3)), 'b'); hold on;
polarplot([0 pi/4 pi/2 3*pi/4 pi 5/4*pi, 3/2*pi, 7/4*pi], (angle(shim3)+pi)./2/pi, 'r'); hold off;

