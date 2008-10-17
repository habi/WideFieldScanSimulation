function SubScans=fct_ImageSlicer(InputImage,DetectorWidth,Overlap_px,showImg)
    wb = waitbar(0,'Please wait...');
    ImageHeight = size(InputImage,1);
    ImageWidth = size(InputImage,2);
    AmountOfSubScans = ceil( ImageWidth / ( DetectorWidth - Overlap_px) )
    EnlargedImage = [ InputImage zeros(ImageHeight,DetectorWidth)];
    SubScans = [struct('Image',[] )];
    EndWidth=Overlap_px+1;
    ConcatenatedImage = [];
    for n=1:AmountOfSubScans
        waitbar(n/AmountOfSubScans)
        StartWidth = EndWidth - Overlap_px;
        EndWidth = StartWidth + DetectorWidth;
        SubScans(n).Image= EnlargedImage(:,StartWidth:EndWidth);
        ConcatenatedImage = [ConcatenatedImage SubScans(n).Image];
    end
    close(wb)          
    if showImg == 1
        figure(1);
            subplot(221)
                imshow(InputImage,[]);
                title('phantom')
                axis on tight
            subplot(222)
                imshow(EnlargedImage,[]);
                title('Enlarged Image')
                axis on tight
            subplot(2,2,[3 4])
                imshow(ConcatenatedImage,[])
                title([num2str(AmountOfSubScans) ' Subscans: sliced and diced'])           
                axis on tight
    end
end