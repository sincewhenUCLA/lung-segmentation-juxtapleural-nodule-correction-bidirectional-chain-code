function [noduleList,existFlag]= drawNodule( inputDirectory,input3DArray,sliceLocationArray )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functtion: read nodule postion information from xlm file and draw the
% nodule location on an input image 3D array
% input: inputDirectory, xml file directory
%        input3DArray, the image array on which the nodule will be drawn
%        sliceLocationArray, the image z position array
% output: noduleList,cell store the nodule contour information
%         existFlag, flag to tell whether there is nodule in current data
%         set; 0 no nodule; 1 have nodule
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     Author: Shiwen Shen 
%     Data: 2013-1-29
%     eamail: sshen@mednet.ucla.edu
%     medical imaging informatics group, UCLA



xDoc = xmlread(inputDirectory);
existFlag=0;
noduleList=getNodule;
viewNodule;




function noduleList=getNodule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% function for calculating the nodule position from the xml file
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%get the readingSession tab
allListitems = xDoc.getElementsByTagName('readingSession');

%get the first readingSession tab and use this radiologist's labeling 
lenthAllList=allListitems.getLength;
indLargeNodule=[];
for iii=0:lenthAllList-1

thisListitem=allListitems.item(iii);

%get all the roi tab in the readingSession
thisList=thisListitem.getElementsByTagName('roi');

%get the nodules with boundary position

for i=0:thisList.getLength-1
    currentList=thisList.item(i);
    xyPositionList=currentList.getElementsByTagName('edgeMap');
    if xyPositionList.getLength>3
        tempal=[iii,i];
        indLargeNodule=[indLargeNodule;tempal];
    end
end
end

%no large nodules
if isempty(indLargeNodule)
    noduleList=[];
    return;
end
noduleList(size(indLargeNodule,1)) = struct('zPosition','','nodulePosition','','noduleGroup','');

for i=1:size(indLargeNodule,1)
    currentList=allListitems.item(indLargeNodule(i,1)).getElementsByTagName('roi').item(indLargeNodule(i,2));
%     currentList=thisList.item(indLargeNodule(i));
    zPositionList=currentList.getElementsByTagName('imageZposition');
    zPositionItem=zPositionList.item(0);
    zPosition=zPositionItem.getFirstChild.getData;
    zPosition=str2double(zPosition);
    noduleList(i).zPosition=zPosition;
    xyPositionList=currentList.getElementsByTagName('edgeMap');
    xyPositionArray=zeros(xyPositionList.getLength,2);
    for j=0:xyPositionList.getLength-1
        xyPosition=xyPositionList.item(j);
        xList=xyPosition.getElementsByTagName('xCoord');
        xItem=xList.item(0);
        x=xItem.getFirstChild.getData;
        x=str2num(x);
        yList=xyPosition.getElementsByTagName('yCoord');
        yItem=yList.item(0);
        y=yItem.getFirstChild.getData;
        y=str2num(y);
        xyPositionArray(j+1,:)=[x,y];
    end
    noduleList(i).nodulePosition=xyPositionArray;
    noduleList(i).noduleGroup=indLargeNodule(i,1);
end
end

function viewNodule
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% this function is used to view the nodule position in the image stack
% 
currenInd=1;
zth=size(input3DArray,3);
figure;
f= gcf;

totalNodule=size(noduleList,2);
imshow(input3DArray(:,:,currenInd),[]);
zPosition=sliceLocationArray(currenInd);%current z postion
hold on;
%find nodules on current slice and draw
for j=1:totalNodule
   if noduleList(j).zPosition==zPosition
      x1=noduleList(j).nodulePosition(:,1);
      y1=noduleList(j).nodulePosition(:,2);
      plot(x1,y1,'Color','red','LineWidth',2);
      existFlag=1;
   end
end
hold off;
% zPositionAll=zeros(totalNodule,1);
% for ii=1:totalNodule
%     zPositionAll(ii)=noduleList(ii).zPosition;
% end
set(f,'KeyPressFcn',@(h_obj,evt) keymove(evt.Key));
set(f,'WindowScrollWheelFcn',@(h_obj,evt) keymove(evt.VerticalScrollCount));


function keymove(key)
    if strcmp(key,'uparrow') || sum(key)==-1 %If the uparrow is pressed or the mouse wheel is turned
        if ( currenInd<zth) 
            currenInd = currenInd+1;   
            imshow(input3DArray(:,:,currenInd),[0,1800]);
            zPosition=sliceLocationArray(currenInd);%current z postion
            hold on;
            %find nodules on current slice and draw
            for i=1:totalNodule
                if noduleList(i).zPosition==zPosition
                    x1=noduleList(i).nodulePosition(:,1);
                    y1=noduleList(i).nodulePosition(:,2);
                    tempRadio=noduleList(i).noduleGroup;
                    switch tempRadio
                        case 0
                            plot(x1,y1,'Color','yellow','LineWidth',2);
%                         case 1
%                             plot(x1,y1,'Color','blue','LineWidth',2);
%                         case 2
%                             plot(x1,y1,'Color','yellow','LineWidth',2);
%                         case 3
%                             plot(x1,y1,'Color','green','LineWidth',2);
                        otherwise
                    end
%                     plot(x1,y1,'Color','red','LineWidth',2);
                     existFlag=1;
                end
            end
            hold off;
            currenInd
        end
    elseif strcmp(key,'downarrow') || sum(key)==1 %If the down arrow or mouse wheel is turned
        if (currenInd>1) 
            currenInd = currenInd-1;
            imshow(input3DArray(:,:,currenInd),[]);
             zPosition=sliceLocationArray(currenInd);%current z postion
            hold on;
            %find nodules on current slice and draw
            for i=1:totalNodule
                if noduleList(i).zPosition==zPosition
                    x1=noduleList(i).nodulePosition(:,1);
                    y1=noduleList(i).nodulePosition(:,2);
                    tempRadio=noduleList(i).noduleGroup;
                    switch tempRadio
                        case 0
                            plot(x1,y1,'Color','red','LineWidth',1);
                        case 1
                            plot(x1,y1,'Color','blue','LineWidth',1);
                        case 2
                            plot(x1,y1,'Color','yellow','LineWidth',1);
                        case 3
                            plot(x1,y1,'Color','green','LineWidth',1);
                        otherwise
                    end
                    existFlag=1;
                end
            end
            hold off;
            currenInd
        end
    end
end
end

end
        
    
