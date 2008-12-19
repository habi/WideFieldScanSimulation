%% Simulation of different Protocols for wide-field-scanning

%% 2008-12-18: starting completely fresh, now that the segment reducer
%% works fine.
%% 2008-12-19: cleanup and documentation.

warning off Images:initSize:adjustingMag % suppress the warning about big images
clear; close all; clc;tic; disp(['It`s now ' datestr(now) ]);disp('-----');

%% User input and value extraction
% User Input is done via an Input Dialog (inputdlg)
InputDialog={...
    'FOV [mm]',...              % 1
    'Binning',...               % 2
    'Magnification',...         % 3
    'Overlap [px]',...          % 4
    'Minimal Quality [%]',...   % 5
    'Maximal Quality [%]',...   % 6
    'Quality Stepwitdh [%]',... % 7
    'SimulationSize [px] (256/512 is a sensible choice...)',...   % 8
    };

% Setup of the Dialog Box
Name='Please Input the parameters or just use the Default ones where applicable';
NumLines=1; % Number of Lines for the Boxes

% The default Answers are...
Defaults={...
    '4.0',...   % 1
    '1',...     % 2
    '10',...    % 3
    '150',...   % 4
    '10',...    % 5
    '100',...   % 6
    '10',...    % 7
    '256',...   % 8
    };
 
% Creates the Dialog box. Input is stored in UserInput array
UserInput=inputdlg(InputDialog,Name,NumLines,Defaults);
 
% Extract the answers from the array
FOV_mm            = str2num(UserInput{1}); % This is the FOV the user wants to achieve
Binning           = str2num(UserInput{2}); % since the Camera is 2048px wide, the binning influences the DetectorWidth
Magnification     = str2num(UserInput{3}); % Magn. and Binning influence the pixelsize
Overlap_px        = str2num(UserInput{4}); % Overlap between the SubScans, needed for merging
MinimalQuality    = str2num(UserInput{5}); % minimal Quality for Simulation
MaximalQuality    = str2num(UserInput{6}); % maximal Quality for Simulation     
QualityStepWidth  = str2num(UserInput{7}); % Quality StepWidth, generalls 10%
SimulationSize_px = str2num(UserInput{8}); % DownSizing Factor for Simulation > for Speedup

%% Calculations needed for progress
pixelsize = 7.4 / Magnification * Binning; % makes Pixel Size [um] equal to second table on TOMCAT website (http://is.gd/citz)

FOV_px = round( FOV_mm * 1000 / pixelsize); % mm -> um -> px
DetectorWidth_px= 2048 / Binning;  % The camera is 2048 px wide > FOV scales with binning

SegmentWidth_px = DetectorWidth_px - Overlap_px;
AmountOfSubScans = ceil( FOV_px / SegmentWidth_px );  

pause(0.001);disp([num2str(AmountOfSubScans) ' SubScans are needed to cover your chosen FOV']);
if mod(AmountOfSubScans,2) == 0 % AmountOfSubScans needs to be odd
    AmountOfSubScans = AmountOfSubScans +1;
    disp(['Since an odd Amount of SubScans is needed, we acquire ' num2str(AmountOfSubScans) ' SubScans.'])
end

ActualFOV_px = AmountOfSubScans * SegmentWidth_px; % this is the real actual FOV, which we aquire
disp(['Your sample could be ' num2str((ActualFOV_px*pixelsize/1000) - FOV_mm) ' mm wider and would still fit into this protocol...']);
disp(['Your sample could be ' num2str(ActualFOV_px - FOV_px) ' pixels wider and would still fit into this protocol...']);

%% Generate 'Table' with Number of Projections
NumberOfProjections = fct_SegmentGenerator(ActualFOV_px,AmountOfSubScans,MinimalQuality,MaximalQuality,QualityStepWidth);

AmountOfProtocols=size(NumberOfProjections,1);

TotalSubScans = sum(NumberOfProjections,2);
[dummy SortIndex] = sort(TotalSubScans);

% plot this table
figure
    plot(TotalSubScans(SortIndex),'-o');
    xlabel('Protocol')
    ylabel('Total NumProj')
    set(gca,'XTick',[1:AmountOfProtocols])
    set(gca,'XTickLabel',SortIndex)


%% Simulating these Protocols to give the end-user a possibility to choose
% Use SimulationSize input at the beginning to reduce the calculations to
% this size, or else it just takes too long...
ModelReductionFactor = SimulationSize_px / ActualFOV_px;
ModelOverlap_px= round( Overlap_px * ModelReductionFactor );
if ModelOverlap_px < 5 % Overlap needs to be above 5 pixels to reliably calculate the merging.
    CorrectedReductionFactor = 5 / Overlap_px ;
    h=helpdlg(['The Overlap for your chose Model Size would be below 5 pixels, '...
        'I`m thus redefining the Reduction Factor from ' num2str(ModelReductionFactor) ...
        ' to ' num2str(CorrectedReductionFactor)],'Tenshun!');
    SimulationSize_px = round( SimulationSize_px * CorrectedReductionFactor / ModelReductionFactor );
    ModelReductionFactor = CorrectedReductionFactor;
    ModelOverlap_px = round(Overlap_px * ModelReductionFactor);
    uiwait(h);
end
pause(0.001);
disp(['The actual FOV is ' num2str(ActualFOV_px) ' pixels, the set ModelSize is ' num2str(SimulationSize_px) ...
    ', we are thus reducing our calculations approx. ' num2str(round(1/ModelReductionFactor)) ' times.']);

ModelNumberOfProjections = round(NumberOfProjections .* ModelReductionFactor);
disp('Generating ModelPhantom...');
ModelImage = imnoise(phantom( round( ActualFOV_px*ModelReductionFactor ) ),'gaussian',0,0.001);
ModelDetectorWidth = round( DetectorWidth_px * ModelReductionFactor );
theta = 1:180/ModelNumberOfProjections(1):180;
disp('Calculating ModelSinogram...');
ModelMaximalSinogram = radon(ModelImage,theta);
disp('Calculating ModelReconstruction...');
ModelMaximalReconstruction = iradon(ModelMaximalSinogram,theta);

for Protocol = 1:size(ModelNumberOfProjections,1)
    disp('---');
    disp(['Working on Protocol ' num2str(Protocol) ' of ' num2str(size(ModelNumberOfProjections,1)) '.']);
    % calculating the error to the original, fullsize protocol
    % uses ModelSinogram and current NumberOfProjections as input
    [ AbsoluteError(Protocol), ErrorPerPixel(Protocol) ] = fct_ErrorCalculation(ModelImage,ModelNumberOfProjections(Protocol,:),ModelMaximalReconstruction);
end

%% Normalizing the Error



Error =  ErrorPerPixel ./ max(ErrorPerPixel);
Error = Error - Error(1);

%% display error
figure
    plot(TotalSubScans(SortIndex),AbsoluteError(SortIndex),'--s');
    xlabel(['Estimated Total Scan Time scaled with Number Of Projections']);
	ylabel('Error: $$\sum\sum\sqrt{DiffImage}$$ [au]','Interpreter','latex');
    grid on;
figure
    plot(TotalSubScans(SortIndex),ErrorPerPixel(SortIndex),'--s');
    xlabel(['Estimated Total Scan Time scaled with Number Of Projections']);
	ylabel('Expected Quality of the Scan [au]');
    grid on;
figure
    plot(TotalSubScans(SortIndex),Error(SortIndex),'--s');
    xlabel(['Estimated Total Scan Time scaled with Number Of Projections']);
    ylabel('Expected Quality of the Scan [%]');
    grid on;
    
%% Let the user choose a protocol
h=helpdlg('Choose 1 square from the quality-plot (quality vs. total scan-time!). One square corresponds to one possible protocol. Take a good look at the time on the left and the quality on the bottom. I`ll then calculate the protocol that best fits your choice','Protocol Selection'); 
uiwait(h);
[ userx, usery ] = ginput(1);
[ mindiff minidx ] = min(abs(TotalSubScans(SortIndex) - userx));
SortedNumProj = NumberOfProjections(SortIndex,:);
User_NumProj = SortedNumProj(minidx,:)

%% finish
disp('-----');
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