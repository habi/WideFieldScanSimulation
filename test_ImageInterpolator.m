clc;
clear all;
close all;

Image1 = imread('s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s20256.tif');
Image2 = imread('s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s20512.tif');
ImageStack(:,:,1) = Image1;
ImageStack(:,:,2) = Image2;

% StartFrom = 512;
% AmountOfImages = 2;
% 
% for Image = 1:AmountOfImages
%     disp([ 'Reading Image Nr. ' num2str(Image) ' of ' num2str(AmountOfImages) ])
%     ImageNumber = sprintf('%04d',StartFrom+Image);
%     ImageStack(:,:,Image) = imread(['s:\SLS\2008c\R108C21Cb_s2\tif\R108C21Cb_s2' num2str(ImageNumber) '.tif' ]);
% end

FromToTo = 128:256+64;
ImageStack = double(ImageStack(FromToTo,FromToTo,:));

x=1:size(ImageStack,1);
y=1:size(ImageStack,2);
z=1:2;

I = fct_ImageInterpolator(ImageStack(:,:,1),ImageStack(:,:,2),3)

InterpolateHowMany = 2;
[xi,yi,zi] = meshgrid(1:size(ImageStack,1),1:size(ImageStack,2),1:(1/(InterpolateHowMany+1)):2);
InterpolatedImageStack = interp3(x,y,z,ImageStack,xi,yi,zi);
    
scrsz = get(0,'ScreenSize');
colormap = [ 0 max(max(max(ImageStack))) ];
figure('Position',[64 scrsz(2)+64 scrsz(3)-128 scrsz(4)-128-32])
	subplot(1,size(zi,3),1)
        imshow(InterpolatedImageStack(:,:,1),colormap)
        title(['Original Slice 1'])
    for ctr=2:size(zi,3)-1
        subplot(1,size(zi,3),ctr)
            imshow(InterpolatedImageStack(:,:,ctr),colormap)
            title(['Interpolated Slice ' num2str(ctr-1) ])
    end
        subplot(1,size(zi,3),size(zi,3))
        imshow(InterpolatedImageStack(:,:,size(zi,3)),colormap)
        title(['Original Slice 2'])