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
Sample = 'R108C04Aa';
Stack = 1;
SubScan = 1;
ReadLinesOfLogFile = 33;

%% Ask the User what SubScans we should merge
h=helpdlg(['Select the logfile of the FIRST SubScan I should merge'],...
    'Instructions');
uiwait(h);
pause(0.01);
StartPath = [ Drive ':' filesep 'SLS' filesep BeamTime filesep 'log' ]
cd(StartPath)
[ LogFile, LogFilePath] = uigetfile('*.log','Select a LogFile','LogFile.log');
[ SubScan Starting Ending] = regexp(LogFile, '_s1', 'match', 'start', 'end');


%% See how many LogFiles we're having...
for i=1:5
    fid = fopen([ LogFilePath LogFile(1:Starting-1) '_s' num2str(i) LogFile(Ending+1:end) ]);
    if fid==-1
        disp([ 'Logfile for SubScan _s' num2str(i) ' does not exist'])
    else
        disp([ 'Logfile for SubScan _s' num2str(i) ' was foud'])
    end
end
break

%%%%
%% Generate Name
SampleName = [ Sample '_B' num2str(Stack) '_s' num2str(SubScan) '_' ];
LogFileLocation = [ Drive ':' filesep 'SLS' filesep BeamTime filesep ...
	'log' filesep SampleName '.log' ];
disp([ 'Reading LogFile ' LogFileLocation ' to extract all relevant Data.']);
disp('---');
%% Read Logfile for parsing the needed Data
% (from http://is.gd/cAYfT)
fid = fopen(LogFileLocation,'r'); % Open text file
LogFile = textscan(fid,'%s',ReadLinesOfLogFile,'delimiter','\n');
LogFile = LogFile{1};
% split LogFile at ':' so we can extract the values
TMP = regexp(LogFile, ':', 'split');
% get Values and strip leading and trailing spaces
UserID = strtrim(TMP{1}{2})
RingCurrent = strtrim(TMP{4}{2})
BeamEnergy = strtrim(TMP{5}{2})
Mono = strtrim(TMP{6}{2})
Objective = strtrim(TMP{8}{2})
Scintillator = strtrim(TMP{9}{2})
ExposureTime = strtrim(TMP{10}{2})
SampleFolder = strtrim(TMP{12}{2})
Projections = strtrim(TMP{14}{2})
Darks = strtrim(TMP{15}{2})
Flats = strtrim(TMP{16}{2})
disp('---');