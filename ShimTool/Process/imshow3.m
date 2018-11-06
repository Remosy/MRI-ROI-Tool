function imshow3(img, range, shape, ImgMap)

%   display 3D volume in 2D concatenation along the 3rd dimension 
%   Jin Jin (uqjjin@uq.edu.au)
%   exampled:
%       imshow3(image, [], [3,5], 'gray'), or simply
%       imshow3(image, [])



img = squeeze(img);
img = img(:,:,:);
[sx,sy,nc] = size(img);

if nargin < 2
    range = [min(img(:)), max(img(:))];
end

if isempty(range)==1
    range = [min(img(:)), max(img(:))];
end

if (nargin < 3) || (numel(shape)==0)
    
    if  ceil(sqrt(nc))^2 ~= nc;
        nc = ceil(sqrt(nc))^2;
        img(end,end,nc)=0;
    end
    
    
    img = reshape(img,sx,sy*nc);
    img = permute(img,[2,3,1]);
    img = reshape(img,sy*sqrt(nc),sqrt(nc),sx);
    img = permute(img,[3,2,1]);
    img = reshape(img,sx*sqrt(nc),sy*sqrt(nc));
    
else
    img = reshape(img,sx,sy*nc);
    img = permute(img,[2,3,1]);
    img = reshape(img,sy*shape(2),shape(1),sx);
    img = permute(img,[3,2,1]);
    img = reshape(img,sx*shape(1),sy*shape(2));
end

%imagesc(img,range); colormap(gray(256));axis('equal');

if nargin < 4
    imshow(img, range);
else
    switch ImgMap
        case 'parula'
            imshow(img, range); colormap parula;
        case 'jet'
            imshow(img, range); colormap jet;
        case 'hsv'
            imshow(img, range); colormap hsv;
        case 'hot'
            imshow(img, range); colormap hot;
        case 'cool'
            imshow(img, range); colormap cool;
        case 'spring'
            imshow(img, range); colormap spring;
        case 'summer'
            imshow(img, range); colormap summer;
        case 'autumn'
            imshow(img, range); colormap autumn;
        case 'winter'
            imshow(img, range); colormap winter;
        case 'gray'
            imshow(img, range); colormap gray;
        case 'bone'
            imshow(img, range); colormap bone;
        case 'copper'
            imshow(img, range); colormap copper;
        case 'pink'
            imshow(img, range); colormap pink;
        case 'lines'
            imshow(img, range); colormap lines;
        case 'colorcube'
            imshow(img, range); colormap colorcube;
        case 'prism'
            imshow(img, range); colormap prism;
        case 'flag'
            imshow(img, range); colormap flag;
        case 'white'
            imshow(img, range); colormap white;
    end
end

