%% takes [NumProj NumProj NumProj] as input and calculates the necessary
%% protocols defined by the user, ranging from MaxQ to MinQ

%% 16.12.2008 - first version
%% 17.12.2008 - sorting now works, groundwork for 5 & 7 subscans
%%             - migrated to fct_v3_SegmentGenerator.m, since this approach seems to work.   


%% reset workspace, start timer
clear;close all;clc;

%% setup
FOV = 1024;
NumProj = round(FOV * pi / 2);
Details = [ NumProj NumProj NumProj ]
MinQ = 40;
MaxQ = 100;
QualityStepWidth = 10;
% LeastQ = 30;    % Cutoff Quality > lower generally doesn't make any sense, except the user says it
% if LeastQ >= MinQ
% 	disp(['since you`ve explicitly set the minimal quality lower than ' ...
%         num2str(LeastQ) '%, i`ve redefined LeastQ to ' num2str(MinQ) '%'])
%     LeastQ = MinQ;
% end

%% calculation
Qualitysteps = (MinQ/100:QualityStepWidth/100:MaxQ/100)'

Protocols = Qualitysteps*Details;

if length(Details)==3
    Protocols = flipud(sort([ Protocols ; [ Protocols(:,1) Protocols(:,2)/2 Protocols(:,1) ]]))
    size(Protocols,1)
elseif length(Details)==5
    disp('not implemented yet')
elseif length(Details)==7
    disp('not implemented yet')
end

%total each row for plotting
TotalSubScans = sum(Protocols,2);
[dummy sortindex] = sort(TotalSubScans);
%% output
plot(TotalSubScans(sortindex));
xlabel('Protocol')
ylabel('Total NumProj')
set(gca,'XTick',[1:size(Protocols,1)])
set(gca,'XTickLabel',sortindex)

%% finish
disp('I`m done with all you`ve asked for...');