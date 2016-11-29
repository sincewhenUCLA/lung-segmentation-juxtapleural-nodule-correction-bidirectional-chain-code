function borderCorrectionResult = chaincodeMaskCorrection2SVMThree( maskRefined,leftRightLobeArea)
%CHAINCODEMASKCORRECTION Summary of this function goes here
%  leftRightLobeArea is a N*2 matrix, N is the slice number in current study. 
%  Each row is a area proportion of the two biggest object.
%  ith slice for debug in maskRefined image stack
% ithlob=1 or 2; 1 for left, 2 for right
% Note: connect all

load SVMStructThreeFeature2.mat
borderCorrectionResult=maskRefined;

sliceNumber=size(maskRefined,3);
%remove the slice with only one connectted object
for i=1:sliceNumber
    if sum(leftRightLobeArea(i,:)>0)~=2
        leftRightLobeArea(i,1)=0;
        leftRightLobeArea(i,2)=0;
    end
end

%find the slice with the biggest lobe area
totalArea=leftRightLobeArea(:,1)+leftRightLobeArea(:,2);
maxLobe=max(totalArea);

for ithSlice=1:sliceNumber
%check each slice to process

    
    %check whether there are two seperated lobes in current slice, jump if not
    if sum(leftRightLobeArea(ithSlice,:)>0)~=2
        continue;
    end
    
    %check whether left and right lobe have similar size, jump if not
     if leftRightLobeArea(ithSlice,1)/leftRightLobeArea(ithSlice,2)>5
         continue;
     end
    
    %check whether the lobe area is big enough
%     if (maxLobe/(leftRightLobeArea(ithSlice,1)+leftRightLobeArea(ithSlice,2)))>4
%         return;
%     end
    
    
%%%%%%%%%%%%%%%%%%%%%%
  %conture corret
%   tepImg=maskRefined(:,:,ithSlice);
  CC = bwconncomp(maskRefined(:,:,ithSlice));
  if CC.NumObjects~=2
      exit('error: object number not equal to 2');
  end
  
  
 for ithlob=1:CC.NumObjects
      img=zeros(size(maskRefined(:,:,ithSlice)));
      img(CC.PixelIdxList{ithlob})=1;
  se = strel('disk',2);
  img=imclose(img,se);
  [bou1,L]=bwboundaries(img);
  b1=bou1{1};
  [cc] = chaincode(b1);
  
  %guassian filter
  sigma=2;
  filterSize=3;
  inX=-filterSize:filterSize;
  gaussianC=1/(sqrt(2*pi)*sigma)*exp(-0.5*inX.^2/(sigma^2));
  sumG=sum(gaussianC);
  gaussianC=gaussianC/sumG;
  
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%precoss upper and lower key points
  chainCode=cc.code;
  
%   chainCode=filter(gaussianC,1,chainCode);
smoothedCode=zeros(size(chainCode));
sizeV=length(chainCode);
for i=1:sizeV
    indexV=i+sizeV-filterSize:i+sizeV+filterSize;
    indexV=mod(indexV,sizeV);
    indexV(indexV==0)=sizeV;
    operateVec=chainCode(indexV);
    smoothedCode(i)=gaussianC*operateVec;
end

%%%%%%%%%%%%%
%test
smoothedCode=round(smoothedCode);


%%%%%%%%%%%



binaCode=zeros(size(chainCode));
binaCode(smoothedCode>4)=1;
binaCode(smoothedCode<4)=-1;
binaCode(smoothedCode==4)=0;
binaCode(smoothedCode==0)=0;

difCode=zeros(size(chainCode));
for i=1:sizeV-1
    difCode(i)=binaCode(i)-binaCode(i+1);
end
difCode(sizeV)=binaCode(sizeV)-binaCode(1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%precoss left and right key points
chainCode2=mod(chainCode+6,8);
smoothedCode2=zeros(size(chainCode));
for i=1:sizeV
    indexV=i+sizeV-filterSize:i+sizeV+filterSize;
    indexV=mod(indexV,sizeV);
    indexV(indexV==0)=sizeV;
    operateVec=chainCode2(indexV);
    smoothedCode2(i)=gaussianC*operateVec;
end



%%%%%%%%%%%%%
%test
smoothedCode2=round(smoothedCode2);


%%%%%%%%%%%


binaCode=zeros(size(chainCode));
binaCode(smoothedCode2>4)=1;
binaCode(smoothedCode2<4)=-1;
binaCode(smoothedCode2==4)=0;
binaCode(smoothedCode2==0)=0;

difCode2=zeros(size(chainCode2));
for i=1:sizeV-1
    difCode2(i)=binaCode(i)-binaCode(i+1);
end
difCode2(sizeV)=binaCode(sizeV)-binaCode(1);
method1Code=(abs(difCode2))|(abs(difCode));


indxV=find(method1Code~=0);
lengthBoundary=length(b1);
t1Search=0.16;%threshold for searching range
t2Search=0.05;
t1Rriao=2;
t2Rriao=1.3;
for i=1:size(indxV,1)
    distanInd=indxV;
    distanInd=distanInd-indxV(i)+1;
    distanInd(distanInd<=0)=distanInd(distanInd<=0)+lengthBoundary;
    
    distanInd(distanInd<=0.5*lengthBoundary)=distanInd(distanInd<=0.5*lengthBoundary)-distanInd(i);
    distanInd(distanInd>0.5*lengthBoundary)=distanInd(i)-distanInd(distanInd>0.5*lengthBoundary)+lengthBoundary+1;
    for j=1:size(indxV,1)
        if distanInd(j)==0
             continue;
         end
         geometicDis=sqrt((b1(indxV(j),1)-b1(indxV(i),1))^2+(b1(indxV(j),2)-b1(indxV(i),2))^2);
         middlePoint=size(img)/2;
         distance2MiddlePoint=sqrt((b1(indxV(j),1)-middlePoint(1))^2+(b1(indxV(j),2)-middlePoint(2))^2);
         
         %cut part ratio
%          if lengthBoundary==0||geometicDis==0||(distanInd(j)/geometicDis)<1||distanInd(j)>0.28*lengthBoundary||geometicDis/size(img,1)>0.09
         if lengthBoundary==0||geometicDis==0||distanInd(j)>0.28*lengthBoundary||geometicDis/size(img,1)>0.09
             continue;
         end
         
         %svm classifying
         sample=[distanInd(j)/geometicDis,distanInd(j)/lengthBoundary,distance2MiddlePoint/sqrt(middlePoint(1)^2+middlePoint(2)^2)];
         Group = svmclassify(SVMStructThreeFeature2,sample);
         
         
%         if ((distanInd(j)<t1Search*lengthBoundary)&&((distanInd(j)/geometicDis)>t1Rriao))||((distanInd(j)<t2Search*lengthBoundary)&&((distanInd(j)/geometicDis)>t2Rriao))...
%                 ||(Group&&(distanInd(j)<0.28*lengthBoundary)&&((distanInd(j)/geometicDis)>1))
         if Group
         lineX=[b1(indxV(i),2),b1(indxV(j),2)];
         lineY=[b1(indxV(i),1),b1(indxV(j),1)];
         X0=b1(indxV(i),1);
         Y0=b1(indxV(i),2);
         X1=b1(indxV(j),1);
         Y1=b1(indxV(j),2);
         img = drawLine(img, X0, Y0, X1, Y1, 1);
        end
        
     end
     
end
img=(img>0);
% se = strel('disk',2);
% img=imclose(img,se);
img=imfill(img,'holes');
borderCorrectionResult(:,:,ithSlice)=borderCorrectionResult(:,:,ithSlice)|img;

end

end
  





