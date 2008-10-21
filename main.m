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
SampleWidth = 1024;
AmountOfSubScans = []; %[] or number. define here if you want to have a certain amount of subscans. then we redefine CameraWidth.
CameraWidth = 256;
Overlap_px  = 100;
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
AmountOfSubScans = length(SubScans);

if ShowSlices ==1 
    figure
        for n=1:length(SubScans)
            subplot(1,length(SubScans),n)
                imshow(SubScans(n).Image)
                axis on tight
        end
end

%notice this is a cell array!
prompt={'Please Enter the Number of Lines I should interpolate over [25]'};
%name of the dialog box
name='Get user Input';
%number of lines visible for your input
numlines=1;
%the default answer
defaultanswer={'25'};
%creates the dialog box. the user input is stored into a cell array
answer=inputdlg(prompt,name,numlines,defaultanswer);
%notice we use {} to extract the data from the cell array
InterpolateXthRow = str2num(answer{1});

whichImage = ceil(AmountOfSubScans/2)
SubScans(whichImage).Image = fct_InterpolateImage(double(SubScans(whichImage).Image),InterpolateXthRow);
figure('name','Interpolated Image')
     imshow(SubScans(whichImage).Image,[])
     axis on

%% cutline generation
disp('the cutlines are:')
for n=1:AmountOfSubScans-1
%    SubScans(n).Cutline=function_cutline(SubScans(n).Image,SubScans(n+1).Image)-1;
    SubScans(n).Cutline = Overlap_px;
    disp(['from image ' num2str(n) ' to ' num2str(n+1) ': ' num2str(SubScans(n).Cutline)])
end
     
%% output
ConcatenatedImage = [];
MergedImage = [];
for n=1:AmountOfSubScans
    ConcatenatedImage = [ ConcatenatedImage SubScans(n).Image ];
    MergedImage = [ MergedImage SubScans(n).Image(:,1:size(SubScans(n).Image,2)-SubScans(n).Cutline)];
end



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