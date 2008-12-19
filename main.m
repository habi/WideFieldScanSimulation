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
prompt={'FOV to achieve (in mm)',...                    %1
    'DetectorWidth (in Pixels)',...                     %2
    'AmountOfSubScans',...                              %3
    'Magnification',...                                 %4
    'Binning',...                                       %5
    'Overlap',...                                       %6
    'UseSheppLogan?',...                                %7
    'ShowSlicingDetails',...                        	%8
    'ShowSlices',...                                    %9
    'Calculate the Cutline? (answering `0`=don`t calculate)',...    %10
    'MaximalQuality',...                                %11
    'MinimalQuality'...                                 %12
    'Simulation-Calculation Size (512,1024,2048)',...   %13
    'writeout',...                                      %14
    'Exposure Time (ms)'};                              %15
name='Input Parameters';
numlines=1;
%the default answer
defaultanswer={'2.6',...  % 1 FOV
    '1024',...          % 2 DetectorWidth
    '[]',...            % 3 How many SubScans?
    '10',...            % 4 Magnification
    '2',...             % 5 Binning
    '100',...           % 6 Overlap
    '1',...             % 7 Use SheppLogan?
    '1',...             % 8 Show Sclicing Details?
    '1',...             % 9 Show the Slices?
    '0',...             %10 Calculate Cutline?
    '100',...           %11 Maximal NumProj Quality
    '20',...            %12 Minimal NumProj Quality
    '512',...           %13 Simulation Calculation Size
    '0',...             %14 writeout
    '100'...            %15 Exposure Time > needed for time estimation
    };
%creates the dialog box. the user input is stored into a cell array

%h=helpdlg('Enter either `DetectorWidth` or `AmountOfSubscans` in the next dialog!','Tenshun!');
%uiwait(h);

answer=inputdlg(prompt,name,numlines,defaultanswer);
%notice we use {} to extract the data from the cell array
FOV_um             = str2num(answer{1});
FOV_um             = FOV_um *1000;
DetectorWidth      = str2num(answer{2}); %[] or number. define here if you want to have a certain amount of subscans. then we redefine DetectorWidth.
AmountOfSubScans   = str2num(answer{3});
Magnification      = str2num(answer{4});
Binning            = str2num(answer{5});
Overlap            = str2num(answer{6});
useSheppLogan      = str2num(answer{7});
ShowSlicingDetails = str2num(answer{8});
ShowSlices         = str2num(answer{9});
CalculateCutline   = str2num(answer{10});
MaximalQuality     = str2num(answer{11});
MinimalQuality     = str2num(answer{12});
ModelWidth         = str2num(answer{13});
writeout           = str2num(answer{14});
ExposureTime       = str2num(answer{15});
pause(0.01)
WorkPath='P:\MATLAB\wfs-sim\';
%% setup data structure to save the stuff into
SubScans = [struct('Image',[],'Cutline',[],'CutImage',[],'NumProj',[],'Sinogram',[],'Reconstruction',[])];

%% calculations
%% AmountOfSubscans

%% calculate pixelsize and amount of subscans
% if AmountOfSubscans is given, we're not setting anything, but using the
% given value
if isempty(AmountOfSubScans) == 1 % none given
    ImageSegmentWidth_px = DetectorWidth - Overlap;
    AmountOfSubScans=ceil( FOV_um / ImageSegmentWidth_px);
    disp(['We need ' num2str(AmountOfSubScans) ' SubScans to cover the chosen FOV']);
    if mod(AmountOfSubScans,2) == 0 % AmountOfSubScans given
        AmountOfSubScans = AmountOfSubScans +1;
        disp(['Since we need an odd Number of SubScans, were adding one, leading to ' num2str(AmountOfSubScans) ' SubScans'])
    end
elseif isempty(AmountOfSubScans) == 0 % AmountOfSubScans is given, we're thus redefining the Detector and the ImageSegmentWidth
    disp(['We`re using  ' num2str(AmountOfSubScans) ' SubScans, as you wish']);
    disp('We`re thus rescaling the DetectorWidth & ImageSegmentWidth to suit your settings!')
    DetectorWidth = ceil(( FOV_um + ((AmountOfSubScans+1)*Overlap))/ AmountOfSubScans);
    ImageSegmentWidth_px = DetectorWidth - Overlap;
    disp(['The new DetectorWidth is ' num2str(DetectorWidth) 'px'])
    disp(['The new ImageSegmentWidth_px is ' num2str(ImageSegmentWidth_px) 'px'])
end

disp(['We`re having ' num2str(AmountOfSubScans*ImageSegmentWidth_px-FOV_um) 'px too much,'])
disp(['since we`re covering ' num2str(FOV_um) 'um with ' num2str(AmountOfSubScans) ' SubScans...'])

% binning and pixelsize
% convert FOV_um into SampleWidth (px) using pixelsize
pixelsize = 7 / Magnification; % according to the table I've used in the NDS-Masterthesis this is the deal.
pizelsize = pixelsize * Binning;
SampleWidth = round( FOV_um / pixelsize );

if useSheppLogan==1
    Image = imnoise(phantom(SampleWidth),'gaussian');
else
    Image = imread([ WorkPath 'R108C04C_merge0001.tif']);
    Image = imresize(Image, [NaN SampleWidth]);
end

% the function saves the sliced subscans in SubScans.Image
%SubScans = fct_ImageSlicer(Image,AmountOfSubScans,DetectorWidth,Overlap,ShowSlicingDetails);

if ShowSlices == 1 
    figure
        for n=1:length(SubScans)
            subplot(1,length(SubScans),n)
                imshow(SubScans(n).Image)
                axis on tight
        end
end

%% cutline generation
disp('the cutlines are:')
for n=1:AmountOfSubScans-1
    % SubScans(n).Image=double(SubScans(n).Image)
    if CalculateCutline == 1
        SubScans(n).Cutline=fct_CutlineCalculator(SubScans(n).Image,SubScans(n+1).Image);
    elseif CalculateCutline == 0
        SubScans(n).Cutline = Overlap/2;
    end
    disp(['from image ' num2str(n) ' to ' num2str(n+1) ': ' num2str(SubScans(n).Cutline)])
end

%% output
% ConcatenatedImage = [];
% MergedImage = [];
% for n=1:AmountOfSubScans-1
%     ConcatenatedImage = [ ConcatenatedImage SubScans(n).Image ];
%     SubScans(n).CutImage = SubScans(n).Image(:,1:size(SubScans(n).Image,2)-abs(SubScans(n).Cutline));
%     MergedImage = [ MergedImage SubScans(n).CutImage ];
% end
% SubScans(AmountOfSubScans).CutImage = SubScans(AmountOfSubScans).Image(:,1:size(SubScans(n).Image,2)-abs(SubScans(n).Cutline));
% ConcatenatedImage = [ ConcatenatedImage SubScans(AmountOfSubScans).Image ];
% MergedImage = [ MergedImage SubScans(AmountOfSubScans).Image ];

ConcatenatedImage = Image;
MergedImage = Image;

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

%NumberOfProjections = fct_v3_SegmentGenerator(SampleWidth,AmountOfSubScans,MinimalQuality,MaximalQuality,10)
NumberOfProjections = fct_segmentreducer(SampleWidth,AmountOfSubScans,MinimalQuality,MaximalQuality)
ProjectionsSize=size(NumberOfProjections);

%% calculate reduction factor for error-calculation
ModelReductionFactor = ModelWidth / SampleWidth;
ModelOverlap= round(Overlap * ModelReductionFactor);
if ModelOverlap < 5
    h=helpdlg('The Overlap for the Model would be below 5 pixels, I`m thus redefining the Reduction Factor','Tenshun!');
    NewReductionFactor = 5/Overlap
    ModelWidth = round(SampleWidth * NewReductionFactor)
    ModelReductionFactor = ModelWidth / SampleWidth
    ModelOverlap = round(Overlap * ModelReductionFactor)
end

Image = MergedImage;

ModelNumberOfProjections = round(NumberOfProjections .* ModelReductionFactor);
ModelImage = imresize(Image,ModelReductionFactor);
ModelDetectorWidth = round(DetectorWidth * ModelReductionFactor);
theta = 1:180/ModelNumberOfProjections(1):180;
ModelMaximalSinogram = radon(ModelImage,theta);
ModelMaximalReconstruction = iradon(ModelMaximalSinogram,theta);

% disp('model sinogram generation')
% ModelSinogram = radon(ModelImage,[0:(179/(max(max(ModelNumberOfProjections))-1)):179]);
% 
% disp('model reconstruction calculation')
% ModelReconstruction = iradon(ModelSinogram,[0:(179/(max(max(ModelNumberOfProjections))-1)):179],...
%         'linear','Ram-lak',1,max(max(ModelNumberOfProjections)));
    
% figure;
%     imshow(ModelSinogram,[]);
% figure;
%     imshow(ModelReconstruction,[]);

for Protocol = 1:size(ModelNumberOfProjections,1)
    disp('---');
    disp(['Working on Protocol ' num2str(Protocol) ' of ' num2str(size(ModelNumberOfProjections,1)) ' in total.']);
    % calculating the error to the original, fullsize protocol
    % uses ModelSinogram and current NumberOfProjections as input
    [ AbsoluteError(Protocol), ErrorPerPixel(Protocol) ] = fct_ErrorCalculation(ModelImage,ModelNumberOfProjections(Protocol,:),ModelMaximalReconstruction);
    TotalScanTime(Protocol) = sum(NumberOfProjections(Protocol,:)) * ExposureTime / 1000;
end

%% Normalizing the Error
% AverageError = max(AverageError) - AverageError;
% QualitySize = InitialQuality - SegmentQuality;
Error =  ErrorPerPixel ./ max(ErrorPerPixel);
Error = Error - Error(1); % erster Fehler substrahieren, damit bestes Protokoll Fehler = 0 hat.
%Error = ( 1 - Error ) .* MaximalQuality;
[ Dummy,SortIndex] = sort(TotalScanTime);

%% display error
figure
    plot(TotalScanTime(SortIndex),AbsoluteError(SortIndex),'--s');
    xlabel(['Estimated Total Scan Time [s] @ an Exposure Time of ' num2str(ExposureTime) ' ms per Proj.']);
	ylabel('Error: $$\sum\sum\sqrt{DiffImage}$$ [au]','Interpreter','latex');
    grid on;
figure
    plot(TotalScanTime(SortIndex),ErrorPerPixel(SortIndex),'--s');
    xlabel(['Estimated Total Scan Time [s] @ an Exposure Time of ' num2str(ExposureTime) ' ms per Proj.']);
	ylabel('Expected Quality of the Scan [au]');
    grid on;
figure
    plot(TotalScanTime(SortIndex),Error(SortIndex),'--s');
    xlabel(['Estimated Total Scan Time [s] @ an Exposure Time of ' num2str(ExposureTime) ' ms per Proj.']);
    ylabel('Expected Quality of the Scan [%]');
    grid on;
    
%% choose which protocol
% h=helpdlg('Choose 1 square from the quality-plot (quality vs. total scan-time!). One square corresponds to one possible protocol. Take a good look at the time on the left and the quality on the bottom. I`ll then calculate the protocol that best fits your choice','Protocol Selection'); 
% uiwait(h);
% [userx,usery] = ginput(1);
% [mindiff minidx ] = min(abs(Error - usery));
% NumberOfProjections = flipud(NumberOfProjections);
% UserNumProj = NumberOfProjections(minidx,:);
% NumberOfProjections = flipud(NumberOfProjections);    
%     
% if writeout == 1
%     %% choose the path
%     h=helpdlg('Now please choose a path where I should write the output-file'); 
%     close;
%     uiwait(h);
%     %UserPath = uigetdir;
%     %pause(0.5);
%     disp('USING HARDCODED UserPATH SINCE X-SERVER DOESNT OPEN uigetdir!!!');
%     UserPath = '/sls/X02DA/Data10/e11126/2008b'
%     %% input samplename
%     UserSampleName = input('Now please input a SampleName: ', 's');
% end
% 
% %% output the NumProj the user wants into Matrix
% ScanWhichTheUserWants = UserNumProj;
% h=helpdlg(['I`ve chosen protocol ' num2str(minidx) ' corresponding to ' num2str(size(NumberOfProjections,2)) ...
%     ' scans with NumProj like this: ' num2str(ScanWhichTheUserWants) ' as a best match to your selection.']);
% uiwait(h);
% % write NumProj to first column of output
% OutputMatrix(:,1)=ceil(ScanWhichTheUserWants);
% 
% %% calculate InbeamPosition
% ImageSegmentWidth_um = ImageSegmentWidth_px * pixelsize;
% UserInbeamPosition=ones(size(ScanWhichTheUserWants,2),1);
% for position = 1:length(UserInbeamPosition)
%     UserInbeamPosition(position) = ImageSegmentWidth_um * position - (ceil(length(UserInbeamPosition)/2)*ImageSegmentWidth_um);
% end
% % write InbeamPositions to second column of output
% OutputMatrix(:,2)=UserInbeamPosition;
% 
% %% set angles
% RotationStartAngle = 45;
% RotationStopAngle  = 225;
% % write angles to second column of output
% OutputMatrix(:,3)=RotationStartAngle;
% OutputMatrix(:,4)=RotationStopAngle;
% 
% if writeout == 1
%     %% write Header to textfile
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], ['# Path = ' UserPath],'delimiter','');
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], ['# SampleName = ' UserSampleName],'-append','delimiter','');
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], ['# FOV = ' num2str(FOV_um) 'um'],'-append','delimiter','');
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], ['# DetectorWidth = ' num2str(DetectorWidth_px) 'px'],'-append','delimiter','');
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], ['# Magnification = ' num2str(Magnification) 'x'],'-append','delimiter','');
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], ['# Binning = ' num2str(Binning) ' x ' num2str(Binning)],'-append','delimiter','');
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], ['# Overlap = ' num2str(Overlap_px) ' px'],'-append','delimiter','');
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], '#---','-append','delimiter','');
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], '# NumProj InBeamPosition StartAngle StopAngle','-append','delimiter','');
%     % dlmwrite([UserPath '/' UserSampleName '.txt' ], '#---','-append','delimiter','');
% 
%     %% write final output matrix to text file
%     dlmwrite([UserPath '/' UserSampleName '.txt' ], OutputMatrix,  '-append', 'roffset', 1, 'delimiter', ' ');
% end    
    
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
