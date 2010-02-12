%% CUTLINE FINDER
% attempts to find the cutlines between two input images
% first version 12.02.2010
clc;clear all;close all;

ProjectionNumber = 1120;
match = [2,3];

%% Loading Images
Tmp = double(imread('C:\Documents and Settings\haberthuer\Desktop\21Bb\DarkImage.tif'));
Dark(:,:,1) = Tmp;
Dark(:,:,2) = Tmp;
Dark(:,:,3) = Tmp;

Tmp = double(imread('C:\Documents and Settings\haberthuer\Desktop\21Bb\FlatImage.tif'));
Flat(:,:,1) = Tmp;
Flat(:,:,2) = Tmp;
Flat(:,:,3) = Tmp;
clear Tmp

Projection(:,:,1) = double(imread([ ...
    'C:\Documents and Settings\haberthuer\Desktop\21Bb\' ...
    'R108C21Bb_s1' sprintf('%04d',ProjectionNumber) ...
    '.tif' ]));
Projection(:,:,2) = double(imread([ ...
    'C:\Documents and Settings\haberthuer\Desktop\21Bb\' ...
    'R108C21Bb_s2' sprintf('%04d',ProjectionNumber) ...
    '.tif' ]));
Projection(:,:,3) = double(imread([ ...
    'C:\Documents and Settings\haberthuer\Desktop\21Bb\' ...
    'R108C21Bb_s3' sprintf('%04d',ProjectionNumber) ...
    '.tif' ]));

CorrProjection = ( Projection - Dark ) ./ Flat;

%% Displaying Images
figure
    subplot(321)
        imshow(Dark(:,:,1),[])
        title('Dark')
    subplot(322)
        imshow(Flat(:,:,1),[])
        title('Flat')
    subplot(323)
        imshow(Projection(:,:,match(1)),[])
        title(['SubScan s' num2str(match(1)) ', Proj ' num2str(ProjectionNumber) ])
    subplot(324)
        imshow(Projection(:,:,match(2)),[])
        title(['SubScan s' num2str(match(2)) ', Proj ' num2str(ProjectionNumber) ])
    subplot(325)
        imshow(CorrProjection(:,:,match(1)),[])
        title(['SubScan s' num2str(match(1)) ', Corrected Proj ' num2str(ProjectionNumber) ])
    subplot(326)
        imshow(CorrProjection(:,:,match(2)),[])
        title(['SubScan s' num2str(match(2)) ', Corrected Proj ' num2str(ProjectionNumber) ])
   
%% Cutline Extraction        
calculatecutline = 1;
if calculatecutline == 0
    if match == [1,2]
        disp('setting cutlines for subscans s1 & s2');
        overlapold = 73;
        overlapnew = 73;
    elseif match == [2,3]
        disp('setting cutlines for subscans s2 & s3');
        overlapold = 65;
        overlapnew = 65;
    end
else
    overlapold = function_cutline(CorrProjection(:,:,match(1)),CorrProjection(:,:,match(2)));
    overlapnew = find_overlap(CorrProjection(:,:,match(1)),CorrProjection(:,:,match(2)),128,2);

    disp([ 'The `old` cutline is ' num2str(overlapold) ', the `new` one is ' num2str(overlapnew) '.' ])

	if overlapold ~= overlapnew
        f = warndlg('The two overlap methods did not yield the same overlap!', 'Overlap Problem!');
    end
end

%% Merging
MergedProjection = [ CorrProjection(:,1:end-overlapold,match(1)) CorrProjection(:,:,match(2)) ];

%% Display Merged Image
figure
    subplot(221)
    	imshow(CorrProjection(:,:,match(1)),[])
        title(['SubScan s' num2str(match(1)) ', Corrected Proj ' num2str(ProjectionNumber) ])
        hold on
        plot(size(Projection,1)-overlapold,1:size(Projection,1),'--rs','LineWidth',2,'Color','g','MarkerSize',2)
    subplot(222)
    	imshow(CorrProjection(:,:,match(2)),[])
        title(['SubScan s' num2str(match(2)) ', Corrected Proj ' num2str(ProjectionNumber) ])
        hold on
        plot(overlapold,1:size(Projection,1),'--rs','LineWidth',2,'Color','r','MarkerSize',2)
    subplot(2,2,3:4)
    	imshow(MergedProjection,[])
        title(['SubScan s' num2str(match(1)) ', Corrected Proj ' num2str(ProjectionNumber) ]) 