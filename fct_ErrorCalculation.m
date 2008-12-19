function [ AbsoluteError, ErrorPerPixel] = fct_ErrorCalculation(Image,NumberOfProjections,MaximalReconstruction)
    AbsoluteError = 0;
    ErrorPerPixel = 0;
    AmountOfSubScans = length(NumberOfProjections);
    if AmountOfSubScans ~=3
        disp('only works for three subscans at the moment')
        return
    end
    
    theta = 1:180/NumberOfProjections(1):180;
    
    Sinogram = radon(Image,theta);
    
    SinogramWidth =  size(Sinogram,1);
    SinogramHeight =  size(Sinogram,2);
    
    CurrentStartPosition = 1;
    SubScanWidth = floor(SinogramWidth / AmountOfSubScans);
    
    for SubScan=1:AmountOfSubScans
        disp(['interpolating SubScan ' num2str(SubScan) ' with ' num2str(NumberOfProjections(SubScan)) ' Projections' ]);
        Region = CurrentStartPosition:CurrentStartPosition+SubScanWidth-1;
        InterpolatedSinogram(Region,:) = fct_InterpolateImage(Sinogram(Region,:),round(NumberOfProjections(1)/NumberOfProjections(SubScan)),1);
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
    
    figure;
        subplot(211)
            imshow(MaximalReconstruction,[])
    %figure;
        subplot(212)
            imshow(InterPolatedReconstruction,[])
  
    DifferenceImage = MaximalReconstruction-InterPolatedReconstruction;
    AbsoluteError = sum( sum( DifferenceImage .^2));
    ErrorPerPixel = AbsoluteError / (SinogramHeight ^2);
end