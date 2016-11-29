function [maskRefined,total1] = maskRefine( maskImageVolume )
%CONTOURCORRETION Summary of this function goes here
%   Detailed explanation goes here
[x,y,z]=size(maskImageVolume);
% viewBinaryMask(maskImageVolume);

%image open 
% se = strel('disk',2);
% for i=1:z
%     maskImageVolume(:,:,i)=imopen(maskImageVolume(:,:,i),se);
% end
% viewBinaryMask(maskImageVolume);

%get left and right lung
total1=zeros(z,2);
for i=1:z

    temple= maskImageVolume(:,:,i)&0;
    CC = bwconncomp(maskImageVolume(:,:,i));
    if CC.NumObjects~=0
        numPixels = cellfun(@numel,CC.PixelIdxList);
        [largest1,idx1] = max(numPixels);
        total1(i,1)=largest1/(x*y);
        numPixels(idx1)=0;
        [largest2,idx2] = max(numPixels);
        total1(i,2)=largest2/(x*y);
        temple(CC.PixelIdxList{idx1}) = 1;
        temple(CC.PixelIdxList{idx2}) = 1;
    else
        total1(i,1)=0;
        total1(i,2)=0;
    end
        
     maskImageVolume(:,:,i)=temple;


end
maskRefined=maskImageVolume;


