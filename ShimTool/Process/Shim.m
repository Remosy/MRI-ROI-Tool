function [shimList_B1p,shimList,mask_shm] = Shim(mask_shm,B1p,B1pGauss,ImagSig)
%Shim Summary of this function goes here
%   Detailed explanation goes here
%gyro = 42.58*1e6*2*pi;
mask_shm = mask_shm > 0;
%mask_shm = logical(mask_shm);
numel(find(mask_shm))
B = zeros(numel(find(mask_shm)), 8);
A_all = reshape(ImagSig, [], 8);

SIZ = size(B1p);
switch numel(SIZ)
    case 3
        NX = SIZ(1); NY = SIZ(2); NC = SIZ(3); NS = 1;
        for ii = 1:NC
            temp = B1pGauss(:,:,ii);
            B(:, ii) = temp(mask_shm);
        end
    case 4
        NX = SIZ(1); NY = SIZ(2); NC = SIZ(4); NS = SIZ(3);
        for ii = 1:NC
            temp = squeeze(B1pGauss(:,:,:,ii));
            % please fix
            %mask_shm_1 = zeros(size(temp));
            %mask_shm_1(:,:,1) = mask_shm;
            %B(:, ii) = temp(mask_shm_1);
            % please fix
            
            B(:, ii) = temp(mask_shm);
        end
    otherwise
        warning('wrong input dimension! Check data!')
end



B1target = 1e-6;    % 1 uT
% Shim 1

% Shim_MagPha, old shim 2
Shim_MagPha = pinv(B)*(B1target.*ones(numel(find(mask_shm)),1));    % shim within ROI
Shim_MagPha = Shim_MagPha./max(abs(Shim_MagPha(:)));                % normalization
B1p_shim_MagPha = reshape(A_all*Shim_MagPha, [NX, NY, NS]);
shimList(:,:,1) = Shim_MagPha;
shimList_B1p(:,:,:,1) = B1p_shim_MagPha;
%figure; imshow3(abs(B1p_shim_MagPha))

% Shim_MagPha_MLS, old shim 4
[Shim_MagPha_MLS, difMLS, TotalIter] = myMLS(B, B1target.*ones(numel(find(mask_shm)),1).*exp(1i.*pi/2), 0.01, 1000);
Shim_MagPha_MLS = Shim_MagPha_MLS./max(abs(Shim_MagPha_MLS(:)));    % normalization
B1p_MagPha_MLS = reshape(A_all*Shim_MagPha_MLS, [NX, NY, NS]);
shimList(:,:,2) = Shim_MagPha_MLS;
shimList_B1p(:,:,:,2) = B1p_MagPha_MLS;
%figure; imshow3(abs(B1p_MagPha_MLS))


% shim_PO: phase-only shim within ROI
AvgPha = angle(mean(B, 1));
shim_PO = exp(-1i.*AvgPha);
B1p_shim_PO = reshape(A_all*transpose(shim_PO), [NX, NY, NS]);
shimList(:,:,3) = shim_PO;
shimList_B1p(:,:,:,3) = B1p_shim_PO;
%figure; imshow3(abs(B1p_shim_PO))


%printf('phase Only shim setting');
%angle(shim_PO)+pi

% shim5: phase-only shim within ROI
%AvgPha = zeros(8, 1);
%for ii = 1:8
%    temp = B1pGauss(:,:,ii);
%    AvgPha(ii) = angle(mean(temp(mask_shm)));
%end
%shim5 = exp(-1i.*AvgPha)*max(abs(shim3));
%B1p_shim5 = reshape(A_all*shim5, size(mask_shm));
%figure;
%subplot(1,2,1); imshow(abs(B1p_shim5),[]); colormap jet; hold on;
%subplot(1,2,2); imshow(angle(B1p_shim5),[]); colormap jet; hold on;
%title('Phase only ROI');


% calculating the inhomogeneity of shimmed B1 within ROI
%difff = abs(B1p_shim3(mask_shm)) - mean(abs(B1p_shim3(mask_shm)));
%sqrt(mean(difff.^2))./mean(abs(B1p_shim3(mask_shm)))

%difff = abs(B1p_shim_MagPha(mask_shm)) - mean(abs(B1p_shim_MagPha(mask_shm)));
%Inhomogeneity_MagPha = sqrt(mean(difff.^2))./mean(abs(B1p_shim_MagPha(mask_shm)));

%difff = abs(B1p_MagPha_MLS(mask_shm)) - mean(abs(B1p_MagPha_MLS(mask_shm)));
%Inhomogeneity_MagPha_MLS = sqrt(mean(difff.^2))./mean(abs(B1p_MagPha_MLS(mask_shm)));

%difff = abs(B1p_shim_PO(mask_shm)) - mean(abs(B1p_shim_PO(mask_shm)));
%Inhomogeneity_PO = sqrt(mean(difff.^2))./mean(abs(B1p_shim_PO(mask_shm)));

%Efficiency_PO = 1;
%Efficiency_MagPha = mean(abs(B1p_shim_MagPha(mask_shm)))./mean(abs(B1p_shim_PO(mask_shm)));
%Efficiency_MagPha_MLS = mean(abs(B1p_MagPha_MLS(mask_shm)))./mean(abs(B1p_shim_PO(mask_shm)));
%EfficiencyList = [Efficiency_MagPha Efficiency_MagPha_MLS Efficiency_PO];


%fl_b1 = B1p_shim_MagPha(:,:,2)
%fl_b1Po =  B1p_shim_PO(:,:,2)
%Efficiency_MagPha = mean(abs(fl_b1(mask_shm)))./mean(abs(fl_b1Po(mask_shm)))
%Efficiency_MagPha_MLS = mean(abs(B1p_MagPha_MLS(mask_shm)))./mean(abs(B1p_shim_PO(mask_shm)));
%EfficiencyList = [Efficiency_MagPha Efficiency_MagPha_MLS Efficiency_PO];

end

