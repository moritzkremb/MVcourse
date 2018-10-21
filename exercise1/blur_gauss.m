%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  img_blurred = blur_gauss(img, sigma)
%  purpose :    blur the image with gaussian filter kernel
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     img:    grayscale input image (m x n), m = number of rows, n = number of columns
%     sigma:  standard deviation of the gaussian kernel
%  output   arguments
%     img_blurred:     blurred image (m x n)
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function img_blurred = blur_gauss(img, sigma)

kernel_width = 2 * round(3 * sigma) + 1; % Kernel size
h = fspecial('gaussian', kernel_width, sigma); % Create Kernel
img_blurred = imfilter(img, h, 'conv', 'replicate'); % convolute image with kernel h


end