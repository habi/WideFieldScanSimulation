%% Simulation of different Protocols for wide-field-scanning
%% complete rewrite for end-user-friendliness

%% 2008-10-10: initial version with splitup into functions and the like.
%% 2008-10-15: splicing into subscans done
%% 2008-10-17: corrected splicing, added

clear; close all; clc;
warning off Images:initSize:adjustingMag % suppress the warning about big ...
    % images, they are still displayed correctly, just a bit smaller..
tic; disp(['It`s now ' datestr(now) ]);

%% setup


prompt={'FOV_um (SampleWidth)','CameraWidth (DetectorWidth_px)','AmountOfSubScans',...
    'Overlap_px','UseSheppLogan?','ShowSlicingDetails','ShowSlices',...
    'Calculate the Cutline? (answering `0` -> hardcoded)','InitialQuality','SegmentQuality'...
    'Reduction Factor for Simulation'};
name='Input Parameters';
numlines=1;
%the default answer
defaultanswer={'2048','[]','3','128','1','0','0','0','100','10','2'};
% %creates the dialog box. the user input is stored into a cell array
answer=inputdlg(prompt,name,numlines,defaultanswer);
%notice we use {} to extract the data from the cell array
SampleWidth        = str2num(answer{1});
CameraWidth        = str2num(answer{2}); %[] or number. define here if you want to have a certain amount of subscans. then we redefine CameraWidth.
AmountOfSubScans   = str2num(answer{3});
Overlap_px         = str2num(answer{4});
useSheppLogan      = str2num(answer{5});
ShowSlicingDetails = str2num(answer{6});
ShowSlices         = str2num(answer{7});
CalculateCutline   = str2num(answer{8});
InitialQuality     = str2num(answer{9});
SegmentQuality     = str2num(answer{10});
ReduceIt           = str2num(answer{11});
pause(0.01)
WorkPath='P:\MATLAB\wfs-sim\';
%% setup data structure to save the stuff into
SubScans = [struct('Image',[],'Cutline',[],'CutImage',[],'NumProj',[],'Sinogram',[],'Reconstruction',[])];
%% calculation
if AmountOfSubScans >= 1
    CameraWidth = ceil(( SampleWidth + ((AmountOfSubScans+1)*Overlap_px))/ AmountOfSubScans)
end

if useSheppLogan==1
    Image = imnoise(phantom(SampleWidth),'gaussian');
else
    Image = imread([ WorkPath 'R108C04C_merge0001.tif']);
    Image = imresize(Image, [NaN SampleWidth]);
end

% the function saves the sliced subscans in SubScans.Image
SubScans = fct_ImageSlicer(Image,CameraWidth,Overlap_px,ShowSlicingDetails);
AmountOfSubScans = length(SubScans);

if ShowSlices == 1 
    figure
        for n=1:length(SubScans)
            subplot(1,length(SubScans),n)
                imshow(SubScans(n).Image)
                axis on tight
        end
end

InterpolateXthRow = 4;
whichImage = ceil(AmountOfSubScans/2);
SubScans(whichImage).Image = fct_InterpolateImage(double(SubScans(whichImage).Image),InterpolateXthRow);
% figure('name','Interpolated Image')
%      imshow(SubScans(whichImage).Image,[])
%      axis on

%% cutline generation
disp('the cutlines are:')
for n=1:AmountOfSubScans-1
    % SubScans(n).Image=double(SubScans(n).Image)
    if CalculateCutline == 1
        SubScans(n).Cutline=fct_cutline(SubScans(n).Image,SubScans(n+1).Image);
    elseif CalculateCutline == 0
        SubScans(n).Cutline = Overlap_px;
    end
    disp(['from image ' num2str(n) ' to ' num2str(n+1) ': ' num2str(SubScans(n).Cutline)])
end
     
%% output
ConcatenatedImage = [];
MergedImage = [];
for n=1:AmountOfSubScans-1
    ConcatenatedImage = [ ConcatenatedImage SubScans(n).Image ];
    SubScans(n).CutImage = SubScans(n).Image(:,1:size(SubScans(n).Image,2)-abs(SubScans(n).Cutline));
    MergedImage = [ MergedImage SubScans(n).CutImage ];
end
SubScans(AmountOfSubScans).CutImage = SubScans(AmountOfSubScans).Image(:,1:size(SubScans(n).Image,2)-abs(SubScans(n).Cutline));
ConcatenatedImage = [ ConcatenatedImage SubScans(AmountOfSubScans).Image ];
MergedImage = [ MergedImage SubScans(AmountOfSubScans).Image ];

figure('name','Images')
    subplot(211)
        imshow(ConcatenatedImage,[])
        axis on
        title('Concatenated Image')
%figure('name','Merged Image')
    subplot(212)
        imshow(MergedImage,[])
        axis on
        title('Merged Image')

NumberOfProjections = fct_segmentreducer((SampleWidth-((AmountOfSubScans-1)*Overlap_px)),...
    SampleWidth,size(SubScans(1).Image,2),AmountOfSubScans,InitialQuality/100,SegmentQuality/100);


%% calculate global reduction factor to speed things up a bit
TotalProj(length(NumberOfProjections(:,1))) = 0;
ConcatenatedReconstructions = [struct('Image',[],'TotalNumProj','0','DiffImage',[],'Error',[])];
for Protocol=1:length(NumberOfProjections(:,1))
    for n=1:AmountOfSubScans
        SubScans(n).NumProj = NumberOfProjections(Protocol,n);
        TotalProj(Protocol) = TotalProj(Protocol) + SubScans(n).NumProj;
        ConcatenatedReconstructions(Protocol).TotalNumProj = TotalProj(Protocol);%ConcatenatedReconstructions(Protocol).TotalNumProj + SubScans(n).NumProj;
    end
    if Protocol == 1
        factor = round(ConcatenatedReconstructions(Protocol).TotalNumProj/(SampleWidth/ReduceIt));
    else
    end
end

%% radon and iradon
for Protocol=1:length(NumberOfProjections(:,1))
    sinbar = waitbar(0,'calculating sinograms...');
%     figure
    for n=1:AmountOfSubScans
        SubScans(n).NumProj = NumberOfProjections(Protocol,n)/factor;
        SubScans(n).Sinogram = radon(SubScans(n).CutImage,1:(180/(SubScans(n).NumProj)):180);
%         subplot(AmountOfSubScans,1,n)
%             imshow(SubScans(n).Sinogram',[])
%             title(['Sinogram Nr. ' num2str(n) ' - Protocol Nr. ' num2str(Protocol) ])
%             axis on
%         pause(0.01)
        waitbar(n/AmountOfSubScans)
    end
    close(sinbar)

    recbar = waitbar(0,'calculating reconstructions...');
    ConcatenatedReconstructions(Protocol).Image = [];
%     figure
    for n=1:AmountOfSubScans
        SubScans(n).Reconstruction = iradon(SubScans(n).Sinogram,1:(180/(SubScans(n).NumProj)):180,...
            'linear','Ram-lak',1,CameraWidth-Overlap_px);
        ConcatenatedReconstructions(Protocol).Image = [ ConcatenatedReconstructions(Protocol).Image SubScans(n).Reconstruction ];
%         subplot(2,AmountOfSubScans,n)
%             imshow(SubScans(n).Reconstruction,[])
%             title(['Reconstruction Nr. ' num2str(n) ' - Protocol Nr. ' num2str(Protocol) ])
%             axis on
%         pause(0.01)
         waitbar(n/AmountOfSubScans)
    end
%         subplot(2,AmountOfSubScans,[(AmountOfSubScans+1) (2*AmountOfSubScans)])
%             imshow(ConcatenatedReconstruction,[])
%             title('Concatenated Reconstructions')
%             axis on
    close(recbar)
    
    figure('Position',[100 100 1536 800],'name',['All Images for Protocol ' num2str(Protocol)])
    for n=1:AmountOfSubScans
        subplot(AmountOfSubScans+2,2,2*n-1)
            imshow(SubScans(n).Sinogram',[])
            title(['Sinogram Nr. ' num2str(n) ' - Protocol Nr. ' num2str(Protocol) ])
            axis on
        subplot(AmountOfSubScans+2,2,2*n)
            imshow(SubScans(n).Reconstruction,[])
            title(['Reconstruction Nr. ' num2str(n) ' - Protocol Nr. ' num2str(Protocol) ])
            axis on
        subplot(AmountOfSubScans+2,2,[(2*AmountOfSubScans)+1 (2*AmountOfSubScans)+4])
            imshow(ConcatenatedReconstructions(Protocol).Image,[])
            title(['Concatenated Reconstructions - Protocol Nr. ' num2str(Protocol)])
            axis on
    end    
end

%% calculate pixelwise Error
for Protocol=1:length(NumberOfProjections(:,1))
    ConcatenatedReconstructions(Protocol).DiffImage = ( ConcatenatedReconstructions(1).Image - ConcatenatedReconstructions(Protocol).Image);
    ConcatenatedReconstructions(Protocol).Error = sum( sum( ConcatenatedReconstructions(Protocol).DiffImage .^2 ) );% / size(ConcatenatedReconstructions(Protocol).Image,1) / size(ConcatenatedReconstructions(Protocol).Image,2);
    figure
        imshow(ConcatenatedReconstructions(Protocol).DiffImage,[])
        title(['Error: ' num2str(ConcatenatedReconstructions(Protocol).Error)])
end

%% display error
figure
    semilogy([ConcatenatedReconstructions.TotalNumProj],[ConcatenatedReconstructions.Error]);
    xlabel('Total Amount of simulated Projections');
	ylabel('Error: $$\sum\sum\sqrt{DiffImage}$$','Interpreter','latex');
    grid on;

%% finish
disp('I`m done with all you`ve asked for...')
disp(['It`s now ' datestr(now) ]);
zyt=toc;sekunde=round(zyt);minute = floor(sekunde/60);stunde = floor(minute/60);
if stunde >= 1
    minute = minute - 60*stunde;
    sekunde = sekunde - 60*minute - 3600*stunde;
    disp(['It took me approx ' num2str(round(stunde)) ' hours, ' ...
        num2str(round(minute)) ' minutes and ' num2str(round(sekunde)) ...
        ' seconds to perform the given task' ]);
else
    minute = minute - 60*stunde;
    sekunde = sekunde - 60*minute;
    disp(['It took me approx ' num2str(round(minute)) ' minutes and ' ...
        num2str(round(sekunde)) ' seconds to perform the given task' ]);
end
%helpdlg('I`m done with all you`ve asked for...','Phew!');