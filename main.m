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
SampleWidth = 2500;
AmountOfSubScans = []; %[] or number. define here if you want to have a certain amount of subscans. then we redefine CameraWidth.
CameraWidth = 512;
Overlap_px  = 50;
useSheppLogan = 0;
ShowSlicingDetails = 1;
ShowSlices = 0;

WorkPath='P:\MATLAB\wfs-sim\';

%% calculation
if AmountOfSubScans >= 1
    CameraWidth = ceil(( SampleWidth + ((AmountOfSubScans+1)*Overlap_px))/ AmountOfSubScans)
end

if useSheppLogan==1
    Image = phantom(SampleWidth);
else
    Image = imread([ WorkPath 'R108C04C_merge0001.tif']);
    Image = imresize(Image, [NaN SampleWidth]);
end

% inside fct_ImageSlicer we're defining SubScans = [struct('Image',[] )];
SubScans = fct_ImageSlicer(Image,CameraWidth,Overlap_px,ShowSlicingDetails);

if ShowSlices ==1 
    figure
        for n=1:length(SubScans)
            subplot(1,length(SubScans),n)
                imshow(SubScans(n).Image)
                axis on tight
        end
end
    
InterpolateImage = Subscans
%% output
% figure('name','Merged Image')
%     imshow(SubScans,[])
%     axis on tight


    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    


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