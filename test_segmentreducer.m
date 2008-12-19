clc;
clear all;

SampleWidth=2600;
DetectorWidth=1024;
Overlap=150;
MaximalQuality=100;
MinimalQuality=90;
NumberOfProjections = fct_segmentreducer(SampleWidth,ceil(SampleWidth/(DetectorWidth-Overlap)),MinimalQuality,MaximalQuality);
  
ProjectionsSize=size(NumberOfProjections)

disp('been there, done that!')