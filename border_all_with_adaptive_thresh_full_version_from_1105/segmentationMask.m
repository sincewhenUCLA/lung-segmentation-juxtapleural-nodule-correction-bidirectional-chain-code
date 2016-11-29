function [maskImageVolume,medianSliceNum]= segmentationMask( intialSegResult,volume_image)
% this fucntion is used to get the lung mask for the 3D input CT image and
% remove the airway mask from the lung region
% input:
% intialSegResult: two phase segmentation result
% volume_image: the reordered 3D CT image array
% airwayMask: segmentation result for airway
% output:
% maskImageVolume: the binary mask of segmentation result
% medianSliceNum: slice with the largest lung mask region is considered as the midian slice

%%%%%%%%%%%%%%%%%%%%%
%get lung lobe region
[width,longth,imageIndexTotal]=size(volume_image);
maskImageVolume=intialSegResult;
maskImageBodyRegion=maskImageVolume;
%  viewBinaryMask(maskImageBodyRegion);
for i=1:imageIndexTotal
    maskImageBodyRegion(:,:,i)=imfill(maskImageBodyRegion(:,:,i),'holes');
end

maskImageVolume=~maskImageVolume;
maskImageVolume(~maskImageBodyRegion)=0;
% maskImageVolume=maskImageVolume&(~airwayMask);




% viewBinaryMask(maskImageVolume)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 3d-connected component labbling to remove other object
CC = bwconncomp(maskImageVolume);
numPixels = cellfun(@numel,CC.PixelIdxList);
[largest1,idx1] = max(numPixels);
numPixels(idx1)=0;
[largest2,idx2] = max(numPixels);
maskImageVolume= maskImageVolume&0;
maskImageVolume(CC.PixelIdxList{idx1}) = 1;
maskImageVolume(CC.PixelIdxList{idx2}) = 1;

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % image holes filling
% % note: 3-d filling result is not satisfactory, 2-d is used here
% for i=1:imageIndexTotal
%     maskImageVolume(:,:,i)=imfill(maskImageVolume(:,:,i),'holes');
% end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%morphorlogical operation
SE = strel('disk', 2);
for i=1:imageIndexTotal
    maskImageVolume(:,:,i)=imopen(maskImageVolume(:,:,i),SE);
%     maskImageVolume(:,:,i)=imerode(maskImageVolume(:,:,i),SE);
    maskImageVolume(:,:,i)=imfill(maskImageVolume(:,:,i),'holes');
end
% viewBinaryMask(maskImageVolume);
% SE = strel('disk', 5);
% for i=1:imageIndexTotal
%     maskImageVolume(:,:,i)=imdilate(maskImageVolume(:,:,i),SE);
%     maskImageVolume(:,:,i)=imerode(maskImageVolume(:,:,i),SE);
%     maskImageVolume(:,:,i)=imfill(maskImageVolume(:,:,i),'holes');
% end

%%%%%%%%%%%%%%%%%%%%%%%%
% slice with the largest lung mask region is considered as the midian slice
medianSliceNum=1;
maxNumber=0;
for i=1:imageIndexTotal
    maskRegion=find(maskImageVolume(:,:,i)==1);
    totalMask=size(maskRegion,1);
    if totalMask>maxNumber
        maxNumber=totalMask;
        medianSliceNum=i;
    end
end
    
    

end

