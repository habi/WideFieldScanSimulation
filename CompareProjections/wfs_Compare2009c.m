clear;close all;clc;
warning off Images:initSize:adjustingMag;

BeamTime = '2009c';
Protocols = ['A','B','C','D','E'];
%Protocols = [ Protocols(1:3) Protocols(5:8) ]
SamplePrefix = 'R108C60B_t';

if isunix == 1 
    UserID = 'e11126';
    %beamline
        % whereamI = '/sls/X02DA/data/';
    %slslc05
        whereamI = '/afs/psi.ch/user/h/haberthuer/slsbl/x02da';
        PathToFiles = [ UserID filesep 'Data10' filesep BeamTime filesep 'mrg' ];
        addpath([ whereamI UserID '/MATLAB'])
        addpath([ whereamI UserID '/MATLAB/SRuCT']) 
else
    whereamI = 'S:';
    PathToFiles = [ 'SLS' filesep BeamTime filesep 'mrg' ];
    addpath('P:\doc\MATLAB')
    addpath('P:\doc\MATLAB\SRuCT')
end

FilePath = fullfile(whereamI, PathToFiles);
    
%% setup
SliceNumber = 1024;
ResizeSize = 2048;

%% read files, threshold them with Otsu and calculate error/similarity
SliceCounter = 1;
for Slice = 1:300:1024
    for ProtocolCounter = 1:size(Protocols,2)
        disp([ 'Working on Slice ' num2str(SliceNumber) ' of Protocol ' Protocols(ProtocolCounter) ]);
            CurrentSample = [ SamplePrefix '-' Protocols(ProtocolCounter) '-mrg' ];
            FileName = [ FilePath filesep CurrentSample filesep 'rec_8bit_' filesep ...
                CurrentSample num2str(SliceNumber) '.rec.8bit.tif' ];
        disp('Reading...');
            Details(ProtocolCounter).RecTif = imread(FileName);
        disp([ 'Slice ' num2str(SliceNumber) ' of Protocol ' Protocols(ProtocolCounter) ...
            ' has a size of ' num2str(size(Details(ProtocolCounter).RecTif,1)) 'x' ...
            num2str(size(Details(ProtocolCounter).RecTif,2)) ' px.' ]);
        disp(['Resizing to ' num2str(ResizeSize) 'x' num2str(ResizeSize) ' px.']);
            Details(ProtocolCounter).RecTif = imresize(Details(ProtocolCounter).RecTif,[ResizeSize NaN]);
        disp('Calculating Otsu Threshold and Thresholding Image...')
            Details(ProtocolCounter).Threshold = graythresh(Details(ProtocolCounter).RecTif);
            Details(ProtocolCounter).ThresholdedSlice = ...
                im2bw(Details(ProtocolCounter).RecTif,Details(ProtocolCounter).Threshold);
        disp(['Threshold is ' num2str(Details(ProtocolCounter).Threshold ...
            * intmax(class(Details(ProtocolCounter).RecTif))) ]);
        disp([ 'Calculating Difference Image to Protocol ' Protocols(1) ])
            Details(ProtocolCounter).DiffImg = imabsdiff( ...
                imresize(Details(ProtocolCounter).ThresholdedSlice,[1024 NaN]), ...
                imresize(Details(1).ThresholdedSlice,[1024 NaN]) ...
                );
            Details(ProtocolCounter).DiffImg = imabsdiff(Details(ProtocolCounter).ThresholdedSlice,Details(1).ThresholdedSlice);
        disp('Calculating the Sum over the Difference Image as an Error-Measure')
            Details(ProtocolCounter).Error = sum( sum( Details(ProtocolCounter).DiffImg ) );      
        disp('Calculating SSIM-Index')
            [mssim ssim_map] = ssim_index(Details(1).RecTif,Details(ProtocolCounter).RecTif);
            Details(ProtocolCounter).SSIM = mssim;
            Details(ProtocolCounter).SSIMMap = ssim_map;
        disp('---')
	ImgError(ProtocolCounter,SliceCounter) = Details(ProtocolCounter).Error;
	ImgSSIM(ProtocolCounter,SliceCounter) = Details(ProtocolCounter).SSIM;
    SliceCounter = SliceCounter + 1;
    end
end

clear CurrentSample;
clear FileName;

for ProtocolCounter = 1:size(Protocols,2)
    figure
        subplot(221)
            imshow(Details(ProtocolCounter).RecTif,[]);
            title([ 'Slice ' num2str(SliceNumber) ' of Protocol ' Protocols(ProtocolCounter) ])
        subplot(222)
            imshow(Details(ProtocolCounter).ThresholdedSlice,[]);
            title([ 'Thresholded with ' num2str(Details(ProtocolCounter).Threshold * intmax(class(Details(ProtocolCounter).RecTif)))])
        subplot(223)
            imshow(Details(ProtocolCounter).DiffImg,[]);
            title([ 'Difference Image to Protocol ' Protocols(1) ])
        subplot(224)
            imshow(Details(ProtocolCounter).SSIMMap,[]);
            title([ 'SSIM = ' num2str(Details(ProtocolCounter).SSIM) ])
end

figure
for ProtocolCounter = 1:size(Protocols,2)
	subplot(1,size(Protocols,2),ProtocolCounter)
    	imshow(Details(ProtocolCounter).SSIMMap,[]);
        title([ 'SSIM(' Protocols(ProtocolCounter) ')=' num2str(Details(ProtocolCounter).SSIM) ])
end

for ProtocolCounter = 1:size(Protocols,2)
    disp([ 'SSIM(' Protocols(ProtocolCounter) ')=' num2str(Details(ProtocolCounter).SSIM) ]);
end

disp('ImgError')
ImgError(ProtocolCounter,SliceCounter) = Details(ProtocolCounter).Error;
disp('ImgSSIM')
ImgSSIM(ProtocolCounter,SliceCounter) = Details(ProtocolCounter).SSIM;

disp('Finished with everything you asked for.');