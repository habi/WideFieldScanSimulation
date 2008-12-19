function OutputImage=fct_InterpolateImage(InputImage,InterpolateEveryXthLnie,varargin)
% function takes InputImage, LineNumberToInterpolate and an - optional -
% third argument to flip the image ("1"). If the third argument is set, the
% image is flipped prior to the interpolation, essentially interpolating
% horizontally
    if InterpolateEveryXthLnie == 1
        OutputImage = InputImage;
        return
    end
    InterpolationDirection = 'vertical';
    if nargin > 2 && varargin{1}
        InterpolationDirection = 'horizontal';
        InputImage = InputImage';
    end
    disp(['interpolating in ' InterpolationDirection ' direction']);
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