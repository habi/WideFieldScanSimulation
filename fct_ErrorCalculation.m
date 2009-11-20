function [ AbsoluteError, ErrorPerPixel] = fct_ErrorCalculation(Image,NumberOfProjections,MaximalReconstruction,SSIM,ShowFigure)
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
    if SSIM == 0
        disp('Calculating the Error with the Sum over the Difference Image!!!!')
        DifferenceImage = imabsdiff(MaximalReconstruction,InterPolatedReconstruction);
        AbsoluteError = sum( sum( DifferenceImage ) );
        disp('Calculating the Error with the Sum over the Difference Image!!!!')
    elseif SSIM == 1
        disp('Calculating the Error with SSIM!!!!')
        [ AbsoluteError, ssim_map ] = ssim_index(MaximalReconstruction,InterPolatedReconstruction);
        AbsoluteError = 1 - AbsoluteError;
        disp('Calculating the Error with SSIM!!!!')
    end
    ErrorPerPixel = AbsoluteError / ( size( MaximalReconstruction,1 ) ^2);
    if ShowFigure == 1
        figure
            subplot(121)
                imshow(InterPolatedReconstruction,[]);
                title('Interpolated Reconstruction')
            subplot(122)
                if SSIM == 0    
                    imshow(DifferenceImage,[]);
                    title('Difference Image');
                elseif SSIM == 1
                    imshow(max(0, ssim_map).^4,[]);
                    title('SSIM Map');
                end
    end
end
