function OutputImage=fct_InterpolateImage(InputImage,InterpolateEveryXthLnie,varargin)
    if InterpolateEveryXthLnie == 1
        OutputImage = InputImage;
        return
    end
    if nargin > 2 && varargin{1}
        disp('reminder: i`ve transposed the image to be interpolated...')
        InputImage = InputImage';
    end
    OutputImage=zeros(size(InputImage,1),size(InputImage,2)); % preallocate for MUCH faster execution
    i = 1:size(InputImage,2);
    OutputImage(:,i) = interp1(1:InterpolateEveryXthLnie:size(InputImage,1),...
        InputImage(1:InterpolateEveryXthLnie:size(InputImage,1),i),...
        1:size(InputImage,1),'linear','extrap');
    %OutputImageSize=size(OutputImage)
    if nargin > 2 && varargin{1}
        OutputImage = OutputImage';
    end
end