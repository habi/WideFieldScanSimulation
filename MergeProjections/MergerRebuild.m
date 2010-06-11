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
Cutline = [];
disp('---');
disp('');
MergeProjections = 0;
ResortProjections = 1;
if MergeProjections == 1;
    disp('Will extract cutline and merge Projections');
    OutPutTifDirName = 'tif_mrg';
elseif MergeProjections == 0
    disp('No Cutline Extraction, we let Prj2Sin handle it');
end
if ResortProjections == 1;
    disp('Resorting Projections for Prj2sin');
    OutPutTifDirName = 'tif_resort';
elseif ResortProjections == 0;
    disp('NOT Resorting Projections, Everything is handled by MATLAB');
end
disp('');
disp('---');

%% Ask the User what SubScans we should merge
% h=helpdlg('Select the logfile of the FIRST SubScan I should merge',...
%     'Instructions');
% uiwait(h);
% pause(0.01);
if isunix==0
    StartPath = [ Drive ':' filesep 'SLS' filesep BeamTime filesep ];
else
    StartPath = [ filesep 'sls' filesep 'X02DA' ];
end
disp(['Opening ' StartPath ' to look for Logfiles'])
[ LogFile, LogFilePath] = uigetfile({'*.log','LogFiles (*.log)'},'Pick the FIRST LogFile',...
          [ StartPath filesep 'LogFile.log' ]);
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
    disp(['Extracting Data from ' Data(i).LogFileName ]);
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
    Data(i).InterFlats = str2double(strtrim(TMP{17}{2}));
    Data(i).InnerScan = str2double(strtrim(TMP{18}{2}));
    Data(i).FlatFreq = str2double(strtrim(TMP{19}{2}));
    Data(i).RotYmin = str2double(strtrim(TMP{20}{2}));
    Data(i).RotYmax = str2double(strtrim(TMP{21}{2}));
    Data(i).AngularStep = str2double(strtrim(TMP{22}{2}));
    Data(i).SampleIn = str2double(strtrim(TMP{23}{2}));
    Data(i).SampleOut = str2double(strtrim(TMP{24}{2}));    
end
disp('---');

%% Display Some Information to User
% Merging
if AmountOfSubScans == 3
    disp('According to the Logfiles we recorded:');      
    for i=1:AmountOfSubScans
        disp([ num2str(Data(i).Projections) ' Projections, ' ...
            num2str(Data(i).NumDarks) ' Darks and '...
            num2str(Data(i).NumFlats) ' Flats for SubScan ' ...
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
if MergeProjections == 1
    disp('Loading Darks and Flats');
    for i=1:AmountOfSubScans
        DarkBar = waitbar(0,[ 'Loading ' num2str(Data(i).NumDarks) ...
            ' Darks for SubScan ' num2str(i)]);
        for k=1:Data(i).NumDarks
            Data(i).Dark(:,:,k) = double(imread([Data(i).SampleFolder filesep ...
                'tif' filesep Data(i).SubScanName sprintf('%04d',k) '.tif' ]));
            waitbar(k/Data(i).NumDarks,DarkBar);
        end
        close(DarkBar)
        FlatBar = waitbar(0,[ 'Loading ' num2str(Data(i).NumFlats) ...
            ' Flats for SubScan ' num2str(i)]);
        for k=1:Data(i).NumFlats
            Data(i).Flat(:,:,k) = double(imread([Data(i).SampleFolder filesep ...
                'tif' filesep Data(i).SubScanName sprintf('%04d',k+Data(i).NumDarks) ...
                '.tif' ]));
            waitbar(k/Data(i).NumFlats,FlatBar);
        end
        close(FlatBar)
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
                title(['avg. Dark _s' num2str(1)],'Interpreter','none')
            subplot(2,3,i+3)
                imshow(Data(i).AverageFlat,[])
                title(['avg. Flat _s' num2str(1)],'Interpreter','none')
        end
    disp('---');
end % MergeProjections == 1

%% Loop over Projections
%% To extract cutline (if wanted)
%% show Files (if wanted)
%% merge Projections (if wanted) or else just write them to disk in a
%% format which prj2sin can understand -> resorted...
disp('---');
disp('Loading Projections');

%% Making new Directory
disp('---');
disp('Extracting Directory-Names of Projectios from all Subscans, making OutpuDirectory')
[ log Starting Ending ] = regexp(LogFilePath, 'log', 'match', 'start', 'end');
OutputDirectory = LogFilePath(1:Starting-1);
[ s1 Starting Ending ] = regexp(Data(1).LogFileName, '_s1', 'match', 'start', 'end');
MergedScanName = [ Data(1).LogFileName(1:Starting) 'mrg'];
OutputDirectory = [OutputDirectory MergedScanName ];
[ success,message] = mkdir([OutputDirectory filesep OutPutTifDirName ]);
if MergeProjections == 1
    what = 'Merging';
elseif ResortProjections == 1
    what = 'Resorting';
end
disp([ 'and ' what ' Files into ' OutputDirectory]);
disp('---');

if Data(1).NumDarks + Data(1).NumFlats + Data(1).Projections ...
    + Data(1).Projections + Data(1).Projections + Data(3).NumFlats > 9999
    Decimal = '%05d';
else
    Decimal = '%04d';
end
    
for i=1:AmountOfSubScans
    disp(['Working on SubScan s' num2str(i) ]); 
    for k=1:Data(i).NumDarks + Data(i).NumFlats + Data(i).Projections + Data(i).NumFlats
        disp(['Working on Projection Nr. ' num2str(k) ' of SubScan ' num2str(i) ]);
    
        %% Cutline Extraction
        if MergeProjections == 1
            % Load Projections
            Data(i).Projection = imread([Data(i).SampleFolder filesep 'tif' ...
                filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ]);
            Data(i).Projection = double(Data(i).Projection);
            Data(i).CorrectedProjection = log(Data(i).AverageFlat - Data(i).AverageDark) - log(Data(i).Projection - Data(i).AverageDark);
    
            disp('Now Merging');
            if isempty(Data(i).Cutline)
                disp('Extracting Cutline, this will take some time');
                disp(['Extracting Cutline between _s' num2str(i) ' and _s' num2str(i+1) ]);
                Data(i).Cutline = function_cutline(Data(i).CorrectedProjection,Data(i+1).CorrectedProjection);
            end
            disp(['The Cutline between _s' num2str(i) ' and _s' num2str(i+1) ' was found to be: ' num2str(Data(i).Cutline) ]);
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
            end %isempty(BlaBla)

% % %             %% Showing Files
% % %             figure('Name',[ 'Projection ' num2str(k) ])
% % %             for i=1:AmountOfSubScans
% % %                 subplot(3,3,i)
% % %                     imshow(Data(i).Projection,[])
% % %                     title(Data(i).SubScanName,'Interpreter','None')
% % %                 subplot(3,3,i+3)
% % %                     imshow(Data(i).CorrectedProjection,[])
% % %                     title(['corr. Proj _s' num2str(i)],'Interpreter','None')                       
% % %             end
% % %                 subplot(3,3,7:9)
% % %                 if MergeProjections == 1
% % %                     imshow(MergedProjection,[])
% % %                     title(['Merged Projections ' num2str(k)])
% % %                 elseif MergeProjections == 0
% % %                     title('Merging will be done by prj2sin')
% % %                 end
% % %             pause(0.001)
        end %MergeProjections
    
    	% Resorting Files for use with Prj2Sin
        if ResortProjections == 1
            % Actually resorting the files
            Data(i).TotalFiles = Data(i).NumDarks + Data(i).NumFlats + ...
                Data(i).Projections + Data(i).NumFlats;
            OriginalFile = [Data(i).SampleFolder filesep 'tif' ...               
                filesep Data(i).SubScanName num2str(sprintf('%04d',k)) '.tif' ];
%             % Since we do NOT want 
%             % - the Flats at the end of s1
%             % - all Darks and Flats for s2 and
%             % - the Darks and Flats at the start of s3, we shift the
%             % output-filenumber for EachSubScan.
%             FileNumberShift(1) = 0;
%             FileNumberShift(2) = Data(1).NumFlats + Data(2).NumDarks + Data(2).NumFlats;
%             FileNumberShift(3) = FileNumberShift(2) + Data(2).NumFlats + Data(3).NumDarks + Data(3).NumFlats;
            DestinationFile = [ OutputDirectory filesep OutPutTifDirName filesep MergedScanName ...
                num2str(sprintf(Decimal,(AmountOfSubScans*k)-(AmountOfSubScans-i))) '.tif' ];
            if isunix
                what = 'Hardlink';
                do = 'ln ';
            else
                what = 'Copy';
                do = 'cp';
            end
            ResortCommand = [ do ' ' OriginalFile ' ' DestinationFile ];
            disp([ what 'ing Files to Merge-Directory' ]);
            disp(ResortCommand);
            system(ResortCommand);        
        end %ResortProjections
    end % k=1:TotalProj
    disp('---');
end % i=1:AmountOfSubScans

disp('Done with Resorting');
disp('---');

disp(['Generating logfile for ' MergedScanName ]);
LogFile = [ OutputDirectory filesep 'tif_resort' filesep MergedScanName '.log' ];
dlmwrite(LogFile, ['User ID : ' Data(1).UserID],'delimiter','');
dlmwrite(LogFile, ['Merged Projections from ' num2str(AmountOfSubScans) ' SubScans to ' MergedScanName '. Log was generated on ' datestr(now) ],'-append','delimiter','');
dlmwrite(LogFile, ['--------------------Beamline Settings-------------------------'],'-append','delimiter','');
dlmwrite(LogFile, ['Ring current [mA]           : ' num2str(mean([Data(1).RingCurrent Data(2).RingCurrent Data(3).RingCurrent])) ],'-append','delimiter','');
dlmwrite(LogFile, ['Beam energy  [keV]          : ' num2str(mean([Data(1).BeamEnergy Data(2).BeamEnergy Data(3).BeamEnergy])) ],'-append','delimiter','');
dlmwrite(LogFile, ['Monostripe                  : ' Data(1).Mono ],'-append','delimiter','');
dlmwrite(LogFile, ['--------------------Detector Settings-------------------------'],'-append','delimiter','');
dlmwrite(LogFile, ['Objective                   : ' num2str(Data(1).Objective) ],'-append','delimiter','');
dlmwrite(LogFile, ['Scintillator                : ' Data(1).Scintillator ],'-append','delimiter','');
dlmwrite(LogFile, ['Exposure time [ms]          : ' num2str(Data(1).ExposureTime) ],'-append','delimiter','');
dlmwrite(LogFile, ['------------------------Scan Settings-------------------------'],'-append','delimiter','');
dlmwrite(LogFile, ['Sample folder                : ' OutputDirectory ],'-append','delimiter','');
dlmwrite(LogFile, ['File Prefix                  : ' MergedScanName ],'-append','delimiter','');
dlmwrite(LogFile, ['Number of projections        : ' num2str(Data(1).Projections + Data(2).Projections + Data(3).Projections) ],'-append','delimiter','');
dlmwrite(LogFile, ['Number of darks              : ' num2str(Data(1).NumDarks + Data(2).NumDarks + Data(3).NumDarks) ],'-append','delimiter','');
dlmwrite(LogFile, ['Number of flats              : ' num2str(2 * (Data(1).NumFlats + Data(2).NumFlats + Data(3).NumFlats)) ],'-append','delimiter','');   
dlmwrite(LogFile, ['Number of inter-flats        : ' num2str(Data(1).InterFlats) ],'-append','delimiter','');
dlmwrite(LogFile, ['Inner scan flag              : ' num2str(Data(1).InnerScan) ],'-append','delimiter','');
dlmwrite(LogFile, ['Flat frequency               : ' num2str(Data(1).FlatFreq) ],'-append','delimiter','');
dlmwrite(LogFile, ['Rot Y min position  [deg]    : ' num2str(Data(1).RotYmin) ],'-append','delimiter','');
dlmwrite(LogFile, ['Rot Y max position  [deg]    : ' num2str(Data(1).RotYmax) ],'-append','delimiter','');
dlmwrite(LogFile, ['Angular step [deg]           : ' num2str(Data(1).AngularStep) ],'-append','delimiter','');
dlmwrite(LogFile, ['Sample In   [um]             : ' num2str(Data(1).SampleIn) ],'-append','delimiter','');
dlmwrite(LogFile, ['Sample Out  [um]             : ' num2str(Data(1).SampleOut) ],'-append','delimiter','');
dlmwrite(LogFile, ['--------------------------------------------------------------'],'-append','delimiter','');

%% Hardlink/Copy LogFile
if isunix
    what = 'Hardlink';
    do = 'ln ';
else
    what = 'Copy';
    do = 'cp';
end
disp([ what 'ing Logfile' ]);
LogFileLinkCommand = [ do ' ' LogFile ' ' LogFilePath MergedScanName '.log' ];
system(LogFileLinkCommand);
disp('----');

%% Sinogram generation.
disp('Generating Sinograms');
if isunix == 1
    SinogramCommand = ( ['prj2sin ' OutputDirectory ' --AppendToScanLog ' ...
        '--scanParameters ' num2str(Data(1).Projections + Data(2).Projections + Data(3).Projections)...
        ',' num2str(Data(1).NumDarks + Data(2).NumDarks + Data(3).NumDarks)...
        ',' num2str(Data(1).NumFlats + Data(2).NumFlats + Data(3).NumFlats)...
        ',0,0 ' ...
        '-j 50 --stitched scan']);
        disp(['Generating Sinograms for ' OutputDirectory ' with the command:']);
        disp([ '"' SinogramCommand '"' ]);
        system(SinogramCommand);
end
disp('----');