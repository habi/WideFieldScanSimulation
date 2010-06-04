%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Rebuild of the Mergeing functions 
% Hopefully more clever implementation with parsing of logfiles and
% using most of the available stuff 
% Initial Version: 3.6.2010
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc;clear all;close all;

%% Setup
Drive = 'R';
BeamTime = '2010b';
ReadLinesOfLogFile = 33;

%% Ask the User what SubScans we should merge
h=helpdlg('Select the logfile of the FIRST SubScan I should merge',...
    'Instructions');
uiwait(h);
pause(0.01);
StartPath = [ Drive ':' filesep 'SLS' filesep BeamTime filesep 'log' ];
disp(['Opening ' StartPath ' to look for Logfiles'])
cd(StartPath)
[ LogFile, LogFilePath] = uigetfile('*.log','Select a LogFile','LogFile.log');
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
disp('---')
disp([ 'I have found ' num2str(AmountOfSubScans) ' logfiles which seem to belong together in ' LogFilePath ])
Data(AmountOfSubScans).Dummy = NaN; % preallocate Structure for Speed-purposes
for i=1:AmountOfSubScans
    disp(['-' LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ]);
    Data(i).LogFileLocation = [ LogFilePath LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ];
	Data(i).LogFileName = [ LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ];
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
    Data(i).RingCurrent = strtrim(TMP{4}{2});
    Data(i).BeamEnergy = strtrim(TMP{5}{2});
    Data(i).Mono = strtrim(TMP{6}{2});
    Data(i).Objective = strtrim(TMP{8}{2});
    Data(i).Scintillator = strtrim(TMP{9}{2});
    Data(i).ExposureTime = strtrim(TMP{10}{2});
    Data(i).SampleFolder = strtrim(TMP{12}{2});
    Data(i).Projections = strtrim(TMP{14}{2});
    Data(i).Darks = strtrim(TMP{15}{2});
    Data(i).Flats = strtrim(TMP{16}{2});
    disp(['Extracting Data from ' Data(i).LogFileName ]);
end
disp('---');

%% Display Some Information to User
% Merging
if AmountOfSubScans == 3
    disp('According to the Logfiles we recorded:');      
    for i=1:AmountOfSubScans
        disp([ num2str(Data(i).Projections) ' Projections for SubScan ' Data(i).SubScanName]);      
    end
else
    disp('Merging for other amount than 3 SubScans not implemented yet...');
    disp('Quitting');
    break
end
disp('---')
% Projections
if Data(1).Projections == Data(2).Projections
    disp('SubScans _s1 and _s2 have an equal amount of Projections.')
    disp('No Interpolation necessary while merging');
    doInterpolate = 0;
else
    disp('SubScans _s1 and _s2 have a different amount of Projections.')
    disp('Interpolating during merging');
    doInterpolate = 1;
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
        Data(i).SampleFolder = [ Drive ':' filesep 'SLS' filesep BeamTime filesep Data(i).SubScanName ];     
    end
end

%% Showing Files
figure
for i=1:AmountOfSubScans
    Data(i).Projection = imread([Data(i).SampleFolder filesep 'tif' filesep Data(i).SubScanName '0128.tif' ]);
    subplot(1,3,i)
    imshow(Data(i).Projection,[])
end