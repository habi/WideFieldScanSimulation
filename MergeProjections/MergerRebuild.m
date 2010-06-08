%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rebuild of the Mergeing functions 
% Hopefully more clever implementation with parsing of logfiles and
% using most of the available stuff 
% Initial Version: 3.6.2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear all;close all;
WasDir = pwd;

%% Setup
Drive = 'R'; BeamTime = '2010b'; % Setup for Windows
ReadLinesOfLogFile = 33; % Lines to read for the Logfile, so we don't read in everything
Cutline = 111;

%% Ask the User what SubScans we should merge
% h=helpdlg('Select the logfile of the FIRST SubScan I should merge',...
%     'Instructions');
% uiwait(h);
% pause(0.01);
if isunix==0
    StartPath = [ Drive ':' filesep 'SLS' filesep BeamTime filesep 'log' ];
else
    StartPath = [ filesep 'sls' filesep 'X02DA' ];
end
disp(['Opening ' StartPath ' to look for Logfiles'])
[ LogFile, LogFilePath] = uigetfile({'*.log','LogFiles (*.log)'},'Pick the FIRST LogFile',...
          [ StartPath filesep 'LogFile.log' ])
[ SubScan Starting Ending] = regexp(LogFile, '_s1', 'match', 'start', 'end');

%% See how many LogFiles we're having...
for i=1:7
    fid = fopen([ LogFilePath LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ]);
    if fid==-1
        disp([ 'Logfile ' LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ' does not exist'])
        AmountOfSubScans = i-1;
        if i==1
            disp('Did you really click on the first Logfile?')
        end
        break
    else
        disp([ 'Logfile ' LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ' foud'])
    end
    if fid ==-1 && i==1
        disp('FUCK')
        break
    end
end
disp([ 'I have found ' num2str(AmountOfSubScans) ' logfiles which seem to belong together in ' LogFilePath ])
if AmountOfSubScans == 0
    disp('Quitting')
    break
end
Data(AmountOfSubScans).Dummy = NaN; % preallocate Structure for Speed-purposes
for i=1:AmountOfSubScans
    Data(i).Cutline = Cutline; % Initialize Cutlines empty (or with value set on Line ~13, so we can skip cutline-detection
end
for i=1:AmountOfSubScans
    disp(['-' LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ]);
    Data(i).LogFileLocation = [ LogFilePath LogFile(1:Starting-1) '_s' ...
        num2str(i) LogFile(Ending+1:end) ];
	Data(i).LogFileName = [ LogFile(1:Starting-1) '_s' num2str(i) ...
        LogFile(Ending+1:end) ];
    Data(i).SubScanName = [ LogFile(1:Starting-1) '_s' num2str(i) '_' ];
end
disp('---')

%% Read Logfile for parsing the needed Data
% (from http://is.gd/cAYfT)
for i=1:AmountOfSubScans
    fid = fopen(Data(i).LogFileLocation);
    LogFile = textscan(fid,'%s',ReadLinesOfLogFile,'delimiter','\n');
    LogFile = LogFile{1};
    TMP = regexp(LogFile, ':', 'split');
    % Above line splits LogFile-lines at ':' so we can extract the values
    % get Values and strip leading and trailing spaces
    Data(i).UserID = strtrim(TMP{1}{2});
    Data(i).RingCurrent = str2double(strtrim(TMP{4}{2}));
    Data(i).BeamEnergy = str2double(strtrim(TMP{5}{2}));
    Data(i).Mono = strtrim(TMP{6}{2});
    Data(i).Objective = str2double(strtrim(TMP{8}{2}));
    Data(i).Scintillator = strtrim(TMP{9}{2});
    Data(i).ExposureTime = str2double(strtrim(TMP{10}{2}));
    Data(i).SampleFolder = strtrim(TMP{12}{2});
    Data(i).Projections = str2double(strtrim(TMP{14}{2}));
    Data(i).NumDarks = str2double(strtrim(TMP{15}{2}));
    Data(i).NumFlats = str2double(strtrim(TMP{16}{2}));
    disp(['Extracting Data from ' Data(i).LogFileName ]);
end
disp('---');

%% Display Some Information to User
% Merging
if AmountOfSubScans == 3
    disp('According to the Logfiles we recorded:');      
    for i=1:AmountOfSubScans
        disp([ num2str(Data(i).Projections) ' Projections for SubScan ' ...
            Data(i).SubScanName]);      
    end
else
    disp('Merging for other amount than 3 SubScans not implemented yet...');
    disp('Quitting');
    break
end
% Projections
Interpolation = Data(1).Projections / Data(2).Projections;
if Interpolation == 1
    disp('SubScans _s1 and _s2 have an equal amount of Projections.')
    disp('No Interpolation necessary while merging');
else
    disp('SubScans _s1 and _s2 have a different amount of Projections.')
    disp('Interpolating during merging');
    disp([ 'Interpolation-Factor from SubScan _s1 to _s2 is ' ...
        num2str(Interpolation) ])
end
disp('---');

%% Construct Paths to read the Files
if isunix == 1
    disp('probably @SLS, using Location from Logfiles')
    for i=1:AmountOfSubScans
        Data(i).SampleFolder
    end
else
    disp('probably @Unibe, constructing new Location')
    for i=1:AmountOfSubScans        
        Data(i).SampleFolder = [ Drive ':' filesep 'SLS' filesep BeamTime ...
            filesep Data(i).SubScanName ];     
    end
end
disp('---');

%%Load Darks and Flats
disp('Loading Darks and Flats');
for i=1:AmountOfSubScans
    for k=1:Data(i).NumDarks
        Data(i).Dark(:,:,k) = imread([Data(i).SampleFolder filesep 'tif' ...
            filesep Data(i).SubScanName sprintf('%04d',k) '.tif' ]);
        Data(i).Dark = double(Data(i).Dark);
    end
    for k=1:Data(i).NumFlats
        Data(i).Flat(:,:,k) = imread([Data(i).SampleFolder filesep 'tif' ...
            filesep Data(i).SubScanName sprintf('%04d',k+Data(i).NumDarks) '.tif' ]);
        Data(i).Flat = double(Data(i).Flat);
    end
end

% Average Darks & Flats
for i=1:AmountOfSubScans
    Data(i).AverageDark = mean(Data(i).Dark,3);
    Data(i).AverageFlat = mean(Data(i).Flat,3);
end

% Show Darks * Flats
figure
    for i=1:AmountOfSubScans
        subplot(2,3,i)
            imshow(Data(i).AverageDark,[])
            title('Dark')
        subplot(2,3,i+3)
            imshow(Data(i).AverageFlat,[])
            title('Flat')
    end
disp('---');

%% Loop over Projections, extract cutline, show files (if necessary), merge
%% projections and write out to disk.
disp('Loading Projections');
for k=500%(Data(i).NumDarks + Data(i).NumFlats +1):750:(Data(i).NumDarks + Data(i).NumFlats + Data(i).Projections + Data(i).NumFlats)
    disp(['Working on Projections ' num2str(k) ]);
    % Load Projections
    for i=1:AmountOfSubScans
        Data(i).Projection = imread([Data(i).SampleFolder filesep 'tif' ...
                filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ]);
        Data(i).Projection = double(Data(i).Projection);
        Data(i).CorrectedProjection = log(Data(i).AverageFlat - Data(i).AverageDark) - log(Data(i).Projection - Data(i).AverageDark);
    end
    
    %% Cutline Extraction
    for i=1:AmountOfSubScans-1
        if isempty(Data(i).Cutline)
            disp('Extracting Cutline, this will take some time');
            disp(['Extracting Cutline between _s' num2str(i) ' and _s' num2str(i+1) ]);
            Data(i).Cutline = function_cutline(Data(i).CorrectedProjection,Data(i+1).CorrectedProjection);
        end
        disp(['The Cutline between _s' num2str(i) ' and _s' num2str(i+1) ' was found to be: ' num2str(Data(i).Cutline) ]);
    end
    disp('---');
    
    %% Merge Projections
    Data(1).CroppedProjection = Data(1).CorrectedProjection(:,1:end-Data(1).Cutline);
    Data(2).CroppedProjection = Data(2).CorrectedProjection;
    Data(3).CroppedProjection = Data(3).CorrectedProjection(:,Data(2).Cutline+1:end);
    MergedProjection = [ Data(1).CroppedProjection Data(2).CroppedProjection Data(3).CroppedProjection ];
    BlaBla = [];
    if isempty(BlaBla)
        disp(['The original Projections have a size of ' num2str(size(Data(1).Projection,1)) ...
            'x' num2str(size(Data(1).Projection,2)) ' pixels.' ]);
        disp(['The cutlines were found to be ' num2str(Data(1).Cutline) ...
            ' (s1:s2) and ' num2str(Data(2).Cutline) ' (s2:s3)']);
        disp(['The merged Projection should thus have ' num2str(size(Data(1).Projection,1)) ...
            'x' num2str((AmountOfSubScans*size(Data(1).Projection,1))-Data(1).Cutline-Data(2).Cutline) ...
            ' pixels ((' num2str(AmountOfSubScans) '*' num2str(size(Data(1).Projection,1)) ...
            ')-' num2str(Data(1).Cutline) '-' num2str(Data(2).Cutline) ')' ]);
        disp(['In realty it has ' num2str(size(MergedProjection,1)) 'x' ...
            num2str(size(MergedProjection,2)) ' pixels' ]);
        BlaBla = 1;
    end
    
    %% Showing Files
    figure('Name',[ 'Projection ' num2str(k) ])
    for i=1:AmountOfSubScans
        subplot(2,3,i)
            imshow(Data(i).Projection,[])
            title(['SubScan _s' num2str(i)],'Interpreter','None')            
    end
        subplot(2,3,4:6)
        imshow(MergedProjection,[])
        title(['Merged and corrected Projections ' num2str(k)])
    pause(0.001)
end