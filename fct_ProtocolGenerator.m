function NumberOfProjections = fct_ProtocolGenerator(SampleWidth_px,AmountOfSubScans,MinimalQuality,MaximalQuality,QualityStepWidth)
%% test
% clc;clear all;close all;
% SampleWidth_px=3714;
% DetectorWidth=1024;
% Overlap=100;
% MaximalQuality=100;
% MinimalQuality=20;
% QualityStepWidth = 10;
% AmountOfSubScans=ceil(SampleWidth_px/(DetectorWidth-Overlap));
%% test
    % calculating base NumberOfProjections 
    BaseNumProj = [ ones(1,AmountOfSubScans)*round(SampleWidth_px*pi/2)];
    disp('-----');
    disp(['I am calculating the Number of Projections for ' num2str(AmountOfSubScans) ' SubScans ' ...
        'and for the Quality Range ' num2str(MinimalQuality) '-' num2str(MaximalQuality) '% in steps of ' num2str(QualityStepWidth) '%.']);
    LeastQuality = 30;    % Cutoff Quality > lower generally doesn't make any sense, except the user says it
    if LeastQuality >= MinimalQuality
        disp(['Since you`ve explicitly set the minimal quality lower than ' ...
            num2str(LeastQuality) '%, i`ve redefined the lowest allowed']);
        disp(['Quality to ' num2str(MinimalQuality) '% instead of the normally ' ...
            'used ' num2str(LeastQuality) '%.'])
        LeastQuality = MinimalQuality;
    end
    Qualities = (MaximalQuality:-QualityStepWidth:MinimalQuality)/100;
    MinimumNumberOfImages = floor( SampleWidth_px * MinimalQuality * 0.01 );
    if MinimumNumberOfImages < 3 
      MinimumNumberOfImages = 3
    end
    NumberOfProjections = [];
    for variations = 1:length(Qualities)
      NumberOfProjections = unique( [ ...
                                      NumberOfProjections;
                                      fct_GenerateSegments( round( SampleWidth_px * Qualities(variations)) ,AmountOfSubScans ,MinimumNumberOfImages) ...
                                    ],'rows');
    end
    NumberOfProjections = flipud(NumberOfProjections);
end
%%%    NumProj = Qualities'*BaseNumProj;
%%% 
%%% %%% 3 SUBSCANS %%%
%%%     if AmountOfSubScans == 3
%%%         NumProj = [ NumProj ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2 NumProj(:,3) ] ;...
%%%             [ NumProj(:,1) NumProj(:,2)/4 NumProj(:,3) ] ;...
%%%             [ NumProj(:,1) NumProj(:,2)/6 NumProj(:,3) ] ;...
%%%             [ NumProj(:,1) NumProj(:,2)/8 NumProj(:,3) ] ;...
%%%             [ NumProj(:,1) NumProj(:,2)/10 NumProj(:,3) ] ;...
%%%             ];
%%% %%% 5 SUBSCANS %%%        
%%%     elseif AmountOfSubScans == 5
%%%         NumProj = [ NumProj ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/2   NumProj(:,4)    NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/2   NumProj(:,4)/2  NumProj(:,5) ] ; ...
%%%             %
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/4   NumProj(:,4)    NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/4   NumProj(:,4)/2  NumProj(:,5) ] ; ...            
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/4   NumProj(:,4)/4  NumProj(:,5) ] ; ...            
%%%             %           
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/6   NumProj(:,4)    NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/6   NumProj(:,4)/2  NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/6   NumProj(:,4)/4  NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/6   NumProj(:,4)/6  NumProj(:,5) ] ; ...
%%%             %            
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/8   NumProj(:,4)    NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/8   NumProj(:,4)/2  NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/8   NumProj(:,4)/4  NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/8   NumProj(:,4)/6  NumProj(:,5) ] ; ...            
%%%             [ NumProj(:,1) NumProj(:,2)/8  NumProj(:,3)/8   NumProj(:,4)/8  NumProj(:,5) ] ; ...            
%%%             %           
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/10  NumProj(:,4)    NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/10  NumProj(:,4)/2  NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/10  NumProj(:,4)/4  NumProj(:,5) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/10  NumProj(:,4)/6  NumProj(:,5) ] ; ...            
%%%             [ NumProj(:,1) NumProj(:,2)/8  NumProj(:,3)/10  NumProj(:,4)/8  NumProj(:,5) ] ; ...                       
%%%             [ NumProj(:,1) NumProj(:,2)/10 NumProj(:,3)/10  NumProj(:,4)/10 NumProj(:,5) ] ; ...                       
%%%             ];
%%%    %%% 7 SUBSCANS %%%
%%%     elseif AmountOfSubScans == 7
%%%         NumProj = [ NumProj ; ...
%%%             % 3
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)    NumProj(:,4)/2  NumProj(:,5)    NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/2  NumProj(:,4)/2  NumProj(:,5)/2  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/2  NumProj(:,4)/2  NumProj(:,5)/2  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             % 6
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)    NumProj(:,4)/4  NumProj(:,5)    NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/2  NumProj(:,4)/4  NumProj(:,5)/2  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/2  NumProj(:,4)/4  NumProj(:,5)/2  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/4  NumProj(:,4)/4  NumProj(:,5)/2  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/4  NumProj(:,4)/4  NumProj(:,5)/4  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/4  NumProj(:,4)/4  NumProj(:,5)/4  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             % 10
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)    NumProj(:,4)/6  NumProj(:,5)    NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/2  NumProj(:,4)/6  NumProj(:,5)/2  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/2  NumProj(:,4)/6  NumProj(:,5)/2  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/4  NumProj(:,4)/6  NumProj(:,5)/4  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/4  NumProj(:,4)/6  NumProj(:,5)/4  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/4  NumProj(:,4)/6  NumProj(:,5)/4  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/6  NumProj(:,4)/6  NumProj(:,5)/6  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/6  NumProj(:,4)/6  NumProj(:,5)/6  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/6  NumProj(:,4)/6  NumProj(:,5)/6  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/6  NumProj(:,4)/6  NumProj(:,5)/6  NumProj(:,6)/6  NumProj(:,7) ] ; ...
%%%             % 15
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)    NumProj(:,4)/8  NumProj(:,5)    NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/2  NumProj(:,4)/8  NumProj(:,5)/2  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/2  NumProj(:,4)/8  NumProj(:,5)/2  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/4  NumProj(:,4)/8  NumProj(:,5)/4  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/4  NumProj(:,4)/8  NumProj(:,5)/4  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/4  NumProj(:,4)/8  NumProj(:,5)/4  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/6  NumProj(:,4)/8  NumProj(:,5)/6  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/6  NumProj(:,4)/8  NumProj(:,5)/6  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/6  NumProj(:,4)/8  NumProj(:,5)/6  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/6  NumProj(:,4)/8  NumProj(:,5)/6  NumProj(:,6)/6  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/8  NumProj(:,4)/8  NumProj(:,5)/8  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/8  NumProj(:,4)/8  NumProj(:,5)/8  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/8  NumProj(:,4)/8  NumProj(:,5)/8  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/8  NumProj(:,4)/8  NumProj(:,5)/8  NumProj(:,6)/6  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/8  NumProj(:,3)/8  NumProj(:,4)/8  NumProj(:,5)/8  NumProj(:,6)/8  NumProj(:,7) ] ; ...
%%%             % 21
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)    NumProj(:,4)/10 NumProj(:,5)    NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/2  NumProj(:,4)/10 NumProj(:,5)/2  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/2  NumProj(:,4)/10 NumProj(:,5)/2  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/4  NumProj(:,4)/10 NumProj(:,5)/4  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/4  NumProj(:,4)/10 NumProj(:,5)/4  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/4  NumProj(:,4)/10 NumProj(:,5)/4  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/6  NumProj(:,4)/10 NumProj(:,5)/6  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/6  NumProj(:,4)/10 NumProj(:,5)/6  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/6  NumProj(:,4)/10 NumProj(:,5)/6  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/6  NumProj(:,4)/10 NumProj(:,5)/6  NumProj(:,6)/6  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/8  NumProj(:,4)/10 NumProj(:,5)/8  NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/8  NumProj(:,4)/10 NumProj(:,5)/8  NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/8  NumProj(:,4)/10 NumProj(:,5)/8  NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/8  NumProj(:,4)/10 NumProj(:,5)/8  NumProj(:,6)/6  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/8  NumProj(:,3)/8  NumProj(:,4)/10 NumProj(:,5)/8  NumProj(:,6)/8  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)    NumProj(:,3)/10 NumProj(:,4)/10 NumProj(:,5)/10 NumProj(:,6)    NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/2  NumProj(:,3)/10 NumProj(:,4)/10 NumProj(:,5)/10 NumProj(:,6)/2  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/4  NumProj(:,3)/10 NumProj(:,4)/10 NumProj(:,5)/10 NumProj(:,6)/4  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/6  NumProj(:,3)/10 NumProj(:,4)/10 NumProj(:,5)/10 NumProj(:,6)/6  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/8  NumProj(:,3)/10 NumProj(:,4)/10 NumProj(:,5)/10 NumProj(:,6)/8  NumProj(:,7) ] ; ...
%%%             [ NumProj(:,1) NumProj(:,2)/10 NumProj(:,3)/10 NumProj(:,4)/10 NumProj(:,5)/10 NumProj(:,6)/10 NumProj(:,7) ] ; ...    
%%%             % then it would be  28
%%%             ];
%%%     else
%%%         disp('-!-!-!-!-');
%%%         disp(['CANNOT CALCULATE PROTOCOLS FOR ' num2str(AmountOfSubScans) ' SUBSCAN(S)']);
%%%         disp('-!-!-!-!-');
%%%         NumberOfProjections = [];
%%%         disp('-----');
%%%         return
%%%     end
%%% 	MiddleScan = ceil(AmountOfSubScans/2);
%%%     NumProj = flipud(sortrows(NumProj));
%%%     % 'Delete' the NumberOfProjections which are smaller than the set
%%%     % LeastQ, which is either 30% or set by the user. The table with
%%%     % NumProj now has a lot of Zeros in it, thus we use 'unique' afterwards
%%%     % to filter those out.
%%% 	for row = 1:size(NumProj,1)
%%%         if NumProj(row,MiddleScan) < round(SampleWidth_px*pi/2*LeastQuality/100)
%%%             AboveLeastQNumProj(row,:) = zeros(1,AmountOfSubScans);
%%%         else
%%%         	AboveLeastQNumProj(row,:) = NumProj(row,:);
%%%         end
%%%     end
%%% 	clear NumProj
%%% 	NumberOfProjections = unique(sortrows(AboveLeastQNumProj),'rows');
%%% %    AboveLeastQNumProj;
%%% 	clear AboveLeastQNumProj
%%% 	% hack to take away the zero NumProj in the first row (coming from the
%%% 	% deletion of the NumProj smaller than LeastQuality).
%%% 	NumberOfProjections = flipud(round(NumberOfProjections(2:end,:)));
%%%     disp(['With your settings, we have ' num2str(size(NumberOfProjections,1)) ' different Scanning Protocols.']);
%%%     disp('-----');
%%% end
