function maskImageVolume= segmentation( volume_image )
% this fucntion is used to get the lung mask for the 3D input CT image
% input:
% volume_image: the reordered 3D CT image array
% output:
% maskImageVolume: the binary mask of segmentation result
% medianSliceNum: slice with the largest lung mask region is considered as the midian slice
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: "Shiwen Shen" <SShen@mednet.ucla.edu>
%          medical imaging informatics group



%%%%%%%%%%%%%%%%%%%%%
% thresholding
[indexY,indexX,indexZ]=size(volume_image);
temImage=zeros(indexY,indexX);
midSliceNum=floor(indexZ/2);
midSlice=volume_image(:,:,midSliceNum);
minValue=min(min(midSlice));
maxValue=max(max(midSlice));
temImage=(midSlice-minValue)*255/(maxValue-minValue);
% thresh_tool(temImage);
% threshValueBe=255*graythreshShen(temImage);
threshValueAf=(maxValue-minValue)*graythreshShen(temImage)+minValue;
[width,longth,imageIndexTotal]=size(volume_image);
maskImageVolume=(volume_image>threshValueAf);
% viewBinaryMask(maskImageVolume);
maskImageBodyRegion=maskImageVolume;

for i=1:imageIndexTotal
    maskImageBodyRegion(:,:,i)=imfill(maskImageBodyRegion(:,:,i),'holes');
end

maskImageVolume=~maskImageVolume;
maskImageVolume(~maskImageBodyRegion)=0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3d-connected component labbling to remove other object

CC = bwconncomp(maskImageVolume);
numPixels = cellfun(@numel,CC.PixelIdxList);
[largest1,idx1] = max(numPixels);
numPixels(idx1)=0;
[largest2,idx2] = max(numPixels);
maskImageVolume= maskImageVolume&0;
maskImageVolume(CC.PixelIdxList{idx1}) = 1;

if largest2~=0
    if (largest1/largest2)<3
        maskImageVolume(CC.PixelIdxList{idx2}) = 1;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% image holes filling
% note: 3-d filling result is not satisfactory, 2-d is used here
for i=1:imageIndexTotal
    maskImageVolume(:,:,i)=imfill(maskImageVolume(:,:,i),'holes');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%morphorlogical operation
SE = strel('disk', 2);
for i=1:imageIndexTotal
%     maskImageVolume(:,:,i)=imopen(maskImageVolume(:,:,i),SE);
%     maskImageVolume(:,:,i)=imerode(maskImageVolume(:,:,i),SE);
    maskImageVolume(:,:,i)=imfill(maskImageVolume(:,:,i),'holes');
end

% mediumImage=maskImageVolume(:,:,floor(indexZ*0.5));
% CC2 = bwconncomp(mediumImage);
% numPixels = cellfun(@numel,CC2.PixelIdxList);
% [largest1_2,idx1_2] = max(numPixels);
% numPixels(idx1_2)=0;
% [largest2_2,idx2_2] = max(numPixels);




end

