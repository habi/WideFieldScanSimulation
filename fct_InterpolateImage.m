function OutputImage=fct_InterpolateImage(InputImage,InterpolateEveryXthLnie)
    OutputImage=zeros(size(InputImage,1),size(InputImage,2)); % preallocate for faster execution
    for i = 1:size(InputImage,2)
        OutputImage(:,i) = interp1(1:InterpolateEveryXthLnie:size(InputImage,1),...
            InputImage(1:InterpolateEveryXthLnie:size(InputImage,1),i),...
            1:size(InputImage,1),'linear','extrap'); 
    end
end