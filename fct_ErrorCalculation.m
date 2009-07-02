function [ AbsoluteError, ErrorPerPixel] = fct_ErrorCalculation(Image,NumberOfProjections,MaximalReconstruction,ShowFigure)
    AbsoluteError = 0;
    ErrorPerPixel = 0;
    AmountOfSubScans = length(NumberOfProjections);
%     if AmountOfSubScans ~=3
%         disp('only works for three subscans at the moment')
%         return
%     end
    
    theta = 1:179/NumberOfProjections(1):180;
    
    Sinogram = radon(Image,theta);
    
    SinogramWidth =  size(Sinogram,1);
    SinogramHeight =  size(Sinogram,2);
    
    CurrentStartPosition = 1;
    SubScanWidth = floor( SinogramWidth / AmountOfSubScans );
    
    for SubScan=1:AmountOfSubScans
        disp(['SubScan ' num2str(SubScan) ' is calculated with ' num2str(NumberOfProjections(SubScan)) ' Projections.' ]);
        Region = CurrentStartPosition:CurrentStartPosition+SubScanWidth-1;
        InterpolatedSinogram(Region,:) = fct_InterpolateImageRows( Sinogram(Region,:),round( NumberOfProjections(1) / NumberOfProjections(SubScan)),1);
        CurrentStartPosition = CurrentStartPosition + SubScanWidth;
    end
    
    % figure;
        % imshow(Sinogram',[])
    % figure;
        % imshow(InterpolatedSinogram',[])
        
    % iradon
    disp('reconstructing interpolated image') 
    InterPolatedReconstruction = iradon(InterpolatedSinogram,theta,'linear','Ram-lak',1,size(MaximalReconstruction,1));

    % size(MaximalReconstruction);
    % size(InterPolatedReconstruction);
         
    DifferenceImage = imabsdiff(MaximalReconstruction,InterPolatedReconstruction);

    AbsoluteError = sum( sum( DifferenceImage ) );
    ErrorPerPixel = AbsoluteError / ( size( MaximalReconstruction,1 ) ^2);
    
    if ShowFigure == 1
        figure;
            subplot(121)
                imshow(InterPolatedReconstruction,[])
                title('Interpolated Reconstruction');
                axis on
            subplot(122)
                imshow(DifferenceImage,[]);
                title('Difference Image');
                axis on
    end
end
