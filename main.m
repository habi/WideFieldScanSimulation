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


prompt={'FOV_um (SampleWidth)','CameraWidth (DetectorWidth_px)','AmountOfSubScans','Overlap_px','UseSheppLogan?','ShowSlicingDetails','ShowSlices'};
name='Input Parameters';
numlines=1;
%the default answer
defaultanswer={'2048','512','[]','25','1','1','0'};
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
pause(0.5)
% prompt={'FOV_um (SampleWidth)','CameraWidth (DetectorWidth_px)','AmountOfSubScans','Overlap_px','Magnification','Binning','Exposure Time','AmountOfDarks','AmountOfFlats','SegmentQuality'};
% name='Input Parameters';
% numlines=1;
% %the default answer
% defaultanswer={'2048','512',[],'25','0','0','0','0','0','0'};
% % %creates the dialog box. the user input is stored into a cell array
% answer=inputdlg(prompt,name,numlines,defaultanswer);
% %notice we use {} to extract the data from the cell array
% SampleWidth = str2num(answer{1});
% AmountOfSubScans = []; %[] or number. define here if you want to have a certain amount of subscans. then we redefine CameraWidth.
% CameraWidth = 512;
% Overlap_px  = 50;
% useSheppLogan = 1;
% ShowSlicingDetails = 1;
% ShowSlices = 0;


WorkPath='P:\MATLAB\wfs-sim\';

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

% inside fct_ImageSlicer we're defining SubScans = [struct('Image',[] )];
SubScans = fct_ImageSlicer(Image,CameraWidth,Overlap_px,ShowSlicingDetails);
AmountOfSubScans = length(SubScans);

if ShowSlices ==1 
    figure
        for n=1:length(SubScans)
            subplot(1,length(SubScans),n)
                imshow(SubScans(n).Image)
                axis on tight
        end
end

InterpolateXthRow = 25;
whichImage = ceil(AmountOfSubScans/2);
SubScans(whichImage).Image = fct_InterpolateImage(double(SubScans(whichImage).Image),InterpolateXthRow);
figure('name','Interpolated Image')
     imshow(SubScans(whichImage).Image,[])
     axis on

%% cutline generation
disp('the cutlines are:')
for n=1:AmountOfSubScans-1
    SubScans(n).Cutline=fct_cutline(SubScans(n).Image,SubScans(n+1).Image)-1;
 %   SubScans(n).Cutline = Overlap_px;
    disp(['from image ' num2str(n) ' to ' num2str(n+1) ': ' num2str(SubScans(n).Cutline)])
end
     
%% output
ConcatenatedImage = [];
MergedImage = [];
for n=1:AmountOfSubScans-1
    ConcatenatedImage = [ ConcatenatedImage SubScans(n).Image ];
    MergedImage = [ MergedImage SubScans(n).Image(:,1:size(SubScans(n).Image,2)-SubScans(n).Cutline)];
end
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

    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


%% finish
disp('I`m done with all you`ve asked for...')
disp(['It`s now ' datestr(now) ]);
zyt=toc;sekunde=round(zyt);minute = round(sekunde/60);stunde = round(minute/60);
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
        num2str(round(sekunde)) ' seconds to perform given task' ]);
end
%helpdlg('I`m done with all you`ve asked for...','Phew!');