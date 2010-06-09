clc;close all;clear all
% Script to find the "overlapping" slice between the top and the bottom
% stack of of a stacked scan.
% Asks User for Input of the two stacks, then tries to find two images with
% minimal difference, which should be the overlapping images...

% First Version: 16.02.2010

%% Setup
warning off Images:initSize:adjustingMag % suppress the warning about big images, they are still displayed correctly, just a bit smaller..
   
Drive = 'R:';
BeamTime = '2010a';
PathToFiles = [ 'SLS' filesep BeamTime filesep 'mrg'];
SamplePath = fullfile(Drive, PathToFiles);
addpath('P:\MATLAB')
addpath('P:\MATLAB\WideFieldScan')
addpath('P:\MATLAB\SRuCT')

ResizeFactor = .25;
SlicesToLoadFromBottomStack = 50;
StepWidth = 1;

%% Loading of the two Stacks
h=helpdlg(['I will now prompt you to select the directories for the two' ...
    ' stacks in which I should look for the "overlap". You only need to ' ...
    ' select the root-directory for each of the stacked Scans, I`ll look ' ...
    ' for the directory with the Reconstructions myself...' ],'Instructions');
uiwait(h);
pause(0.01);

% Let the user choose the location of the two stacked scans
location = [{'top'},{'bottom'}];
for CurrentStack = 1:2
    % User picks base-directory of the Scan
    Details(CurrentStack).Location = uigetdir(SamplePath,...
        cell2mat(['Please locate Directory of the ' location(CurrentStack) ...
        ' scan.']));
    % fileparts extracts the name of the scan, so we can use it later for
    % the filenames
    [ tmp,Details(CurrentStack).Name,tmp ] = ...
       fileparts(Details(CurrentStack).Location);
   disp(['Stack ' num2str(CurrentStack) '/2: ' Details(CurrentStack).Name ]);
end

disp('---')

% Display the names so the user can control the location
for CurrentStack = 1:2
    disp(cell2mat([ 'The ' location(CurrentStack) ' stack (' Details(CurrentStack).Name ...
        ') is located at ' Details(CurrentStack).Location ]));
end

disp('---')

%% Loat bottom file of the top Stack
disp(cell2mat([ 'Loading the last slice of the ' location(CurrentStack) ' stack.']));
FoundSlice = 0;
while FoundSlice == 0
    RecName = 'rec_8bit';
    SliceNumber = 2048;
    Details(1).TopStackLastSlice = [ Details(1).Location filesep RecName ...
        filesep Details(1).Name num2str(sprintf('%04d',SliceNumber)) '.rec.8bit.tif' ];
    % disp(['Trying to read Slice ' num2str(SliceNumber) ' in Directory ' RecName ])
    fid = fopen(Details(1).TopStackLastSlice);
    if fid == -1
%         disp([ 'Slice ' num2str(SliceNumber) ' in Directory ' RecName ' of ' ...
%             Details(1).Name ' does NOT exist!']);
        SliceNumber = 1024;
        Details(1).TopStackLastSlice = [ Details(1).Location filesep RecName ...
            filesep Details(1).Name num2str(sprintf('%04d',SliceNumber)) '.rec.8bit.tif' ];
%         disp(['Trying to read Slice ' num2str(SliceNumber) ' in Directory ' RecName ])
        fid = fopen(Details(1).TopStackLastSlice);
        if fid == -1
%             disp([ 'Slice ' num2str(SliceNumber) ' in Directory ' RecName ...
%                 ' of ' Details(1).Name ' does NOT exist!']);
            RecName = 'rec_8bit_';
            SliceNumber = 2048;
            Details(1).TopStackLastSlice = [ Details(1).Location filesep RecName ...
                filesep Details(1).Name num2str(sprintf('%04d',SliceNumber)) '.rec.8bit.tif' ];
%             disp(['Trying to read Slice ' num2str(SliceNumber) ' in Directory ' RecName ])
            fid = fopen(Details(1).TopStackLastSlice);
            if fid == -1
%                 disp([ 'Slice ' num2str(SliceNumber) ' in Directory ' RecName ' of ' ...
%                     Details(1).Name ' does NOT exist!']);
                SliceNumber = 1024;
                Details(1).TopStackLastSlice = [ Details(1).Location filesep RecName ...
                    filesep Details(1).Name num2str(sprintf('%04d',SliceNumber)) '.rec.8bit.tif' ];
%                 disp(['Trying to read Slice ' num2str(SliceNumber) ' in Directory ' RecName ])
                fid = fopen(Details(1).TopStackLastSlice);
                if fid == -1
                    disp('I could not find neiter Slice 1024 nor Slice 2048 in the Directories rec_8bit or rec_8bit_')
                    disp('I am giving up!')
                    disp('And am stopping the Script here!')
                    break
                else
                    FoundSlice = 1;
                end
            else
                FoundSlice = 1;
            end
        else
            FoundSlice = 1;            
        end
    else
        FoundSlice = 1;
    end
end

% Read Slice
if FoundSlice == 1
    disp(['Reading Slice ' num2str(SliceNumber) ' in Directory ' Details(1).Name filesep RecName ]);
	Details(1).TopStackLastSliceName = Details(1).TopStackLastSlice;
    Details(1).TopStackLastSlice = imread(Details(1).TopStackLastSliceName);
    Details(1).TopStackLastSlice = imresize(Details(1).TopStackLastSlice, ResizeFactor , 'nearest');
else
    break
end

% Display Slice
figure;
    imshow(Details(1).TopStackLastSlice,[]);
    title([ Details(1).Name ', Slice ' num2str(SliceNumber) ],'Interpreter','none');

disp('---');

%% Load 'SlicesToLoadFromBottomStack' Files from bottom Stack
if StepWidth == 1 
    Text = 'every Slice';
else
    Text = ['every ' num2str(StepWidth) 'th Slice'];
end
disp([ 'Reading ' Text ' of the ' num2str(SlicesToLoadFromBottomStack) ' first Slices in Directory ' Details(2).Name filesep RecName ]);  
w = waitbar(0,'Loading Slice');
Details(2).BottomStack(size(Details(1).TopStackLastSlice,1),size(Details(1).TopStackLastSlice,2),SlicesToLoadFromBottomStack) = NaN; % Preallocate Bottom Stack
Details(2).Difference(1:SlicesToLoadFromBottomStack) = NaN; % Preallocate Difference
Detail(2).Correlation(1:SlicesToLoadFromBottomStack) = NaN; % Preallocate Correlation
for SliceNumber = 1:StepWidth:SlicesToLoadFromBottomStack
	waitbar(SliceNumber/SlicesToLoadFromBottomStack,w,[ 'Loading Slice ' ...
        num2str(SliceNumber) '/' num2str(SlicesToLoadFromBottomStack) ' and ' ...
        'extracting Difference/Correlation' ]);
    Details(2).BottomStackFileName(SliceNumber).Name = [ Details(2).Location filesep RecName ...
        filesep Details(2).Name num2str(sprintf('%04d',SliceNumber)) '.rec.8bit.tif' ];
    TMP = imread(Details(2).BottomStackFileName(SliceNumber).Name);
    TMP = imresize(TMP, [ size(Details(1).TopStackLastSlice,1) size(Details(1).TopStackLastSlice,2) ], 'nearest'); % Resize to the same Size as TopStackLastSlice
    Details(2).BottomStack(:,:,SliceNumber) = TMP;
    Details(2).Difference(SliceNumber) = sum(sum(imabsdiff(double(Details(1).TopStackLastSlice),double(TMP))));
%     Details(2).Correlation(SliceNumber) = max(max(normxcorr2(double(Details(1).TopStackLastSlice),double(TMP))));
end
clear TMP; close(w);

disp('---')

%% Find Minima/Maxima and Index of it
[DiffMin,DiffMinIdx] = min(Details(2).Difference);
% [CorrMax,CorrMaxIdx] = max(Details(2).Correlation);

disp([ 'The Difference Minima is at Image ' num2str(DiffMinIdx) ', thus you need to load Image ' Details(2).BottomStackFileName(DiffMinIdx).Name ]);
% disp([ 'The Correlation Maxima is at Image ' num2str(CorrMaxIdx) ', thus you need to load Image ' Details(2).BottomStackFileName(DiffMinIdx).Name ]);

disp('---')

disp([ 'Difference: Match ' Details(1).TopStackLastSliceName ' with ' Details(2).BottomStackFileName(DiffMinIdx).Name ]);
% disp([ 'Correlation: Match ' Details(1).TopStackLastSliceName ' with ' Details(2).BottomStackFileName(DiffMinIdx).Name ]);

disp('---')


%% Plot Correlation and Difference with Index
figure
%     subplot(121)
        plot(Details(2).Difference(1:StepWidth:end))
        title(['Difference Minima is found  @ Image ' num2str(DiffMinIdx)])
%     subplot(122)
%         plot(Details(2).Correlation(1:StepWidth:end))
%         title(['Correlation Maximum is found  @ Image ' num2str(CorrMaxIdx)])