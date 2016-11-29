%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  main.m: main function for test border correstion on all studies with 4
%  radiologists anotations
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Author: "Shiwen Shen" <SShen@mednet.ucla.edu
% 
% Version: 1.0
clc;
clear;
close all;
wkdir = pwd;

dataDirectory='/Volumes/shiwen/LIDC side nodule data set different usage/LIDC_Side_test/';
% dataDirectory='/Volumes/shiwen/LIDC side nodule data set different usage/LIDC_manuual_segmentation/';
% dataDirectory='/Users/shiwenshen/LIDC manual segmentation/';
% outputDirectory='E:\LIDC side nodule data set different usage\LIDC_Side_test_output\';
patientCaseFolderList=dir(dataDirectory);
patientCaseFolderList(1:2)=[];
featureList=[];
rangMatrix=[];
maxTemp=[];
minTemp=[];
for i = 1:length(patientCaseFolderList)

    patientCase=[dataDirectory patientCaseFolderList(i).name '/'];
    patientCasef1=dir(patientCase);
    patientCasef1(1:2)=[];
    patientCase1=[patientCase patientCasef1(1).name '/'];
    patientCasef2=dir(patientCase1);
    patientCasef2(1:2)=[];
    patientCase2=[patientCase1 patientCasef2(1).name '/'];
    [volume_image,sliceLocationArray,xyzSpacing]=dataReorganize(patientCase2);
    cd(patientCase2);
    d = dir('*.xml');
    inputFile=[patientCase2 d.name];
    viewBinaryMask(volume_image);
    [noduleList,existFlag]= drawNodule( d.name,volume_image,sliceLocationArray );
    cd(wkdir);
    
    maskImageVolume= segmentation( volume_image );
%     viewBinaryMask(maskImageVolume);
% [noduleList,existFlag]= drawNodule( xmlInput,maskImageVolume,sliceLocationArray );
[maskRefined,total1] = maskRefine( maskImageVolume );
% viewBinaryMask(maskRefined);
tic
borderCorrectionResult = chaincodeMaskCorrection2SVMThree( maskRefined,total1);
toc
% viewBinaryMask(borderCorrectionResult);
borderCorrectionResult=borderCorrectionResult|maskImageVolume;
finalView=volume_image;
finalView(~borderCorrectionResult)=-1000;
viewBinaryMask(finalView);
    

    
end