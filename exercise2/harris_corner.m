%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [ I, Ixx, Iyy, Ixy, Gxx, Gyy, Gxy, Hdense, Hnonmax, Corners] = 
%                                                            harris_corner(Igray, parameters )
%  purpose :    Harris Corner Detector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     Igray:          grayscale input image, value range: 0-255 (m x n)
%     parameters:     struct containing the following elements:
%		parameters.sigma1: sigma for the first Gaussian filtering
%		parameters.sigma2: sigma for the second Gaussian filtering
%       parameters.k: coefficient for harris formula
%       parameters.threshold: corner threshold
%
%  output   arguments
%     I:              grayscale input image, value range: 0-1 (m x n)
%     Ixx:            squared input image filtered with derivative of gaussian in
%                     x-direction (m x n)
%     Iyy:            squared input image filtered with derivative of gaussian in
%                     y-direction (m x n)
%     Ixy:            Multiplication of input image filtered with
%                     derivative of gaussian in x- and y-direction (m x n)
%     Gxx:            Ixx filtered by larger gaussian (m x n)
%     Gyy:            Iyy filtered by larger gaussian (m x n)
%     Gxy:            Ixy filtered by larger gaussian (m x n)
%     Hdense:         Result of harris calculation for every pixel. Values 
%                     normalized to 0-1 (m x n)
%     Hnonmax:        Binary mask of non-maxima suppression. 1 where values are NOT
%                     suppressed, 0 where they are. (m x n)
%     Corners:        n x 3 matrix containing all detected corners after
%                     thresholding and non-maxima suppression. Every row
%                     vector represents a corner with the elements
%                     [y, x, d] (d is the result of the harris calculation)
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [I, Ixx, Iyy, Ixy, Gxx, Gyy, Gxy, Hdense, Hnonmax, Corners] = harris_corner(Igray, parameters)

%Normalize
Igray = double(Igray); %convert to double
I = Igray/max(Igray(:)); %normalize to 0-1

%Nr of rows and columns
numOfRows = size(I, 1);
numOfColumns = size(I, 2);

%Calculate Ixx, Iyy and Ixy
kernel_width = 2 * round(3 * parameters.sigma1) + 1;
gauss_kernel = fspecial('gaussian', kernel_width, parameters.sigma1); 
[DGx, DGy] = gradient(gauss_kernel);

Ix = imfilter(I, DGx, 'conv', 'replicate');
Iy = imfilter(I, DGy, 'conv', 'replicate');

Ixx = Ix .* Ix;
Iyy = Iy .* Iy;
Ixy = Ix .* Iy;

%Calculate Gxx, Gyy and Gxy
kernel_width2 = 2 * round(3 * parameters.sigma2) + 1;
large_gauss_kernel = fspecial('gaussian', kernel_width2, parameters.sigma2);

Gxx = imfilter(Ixx, large_gauss_kernel, 'conv', 'replicate');
Gyy = imfilter(Iyy, large_gauss_kernel, 'conv', 'replicate');
Gxy = imfilter(Ixy, large_gauss_kernel, 'conv', 'replicate');

%Harris formula (with normalized Image)
Hdense = zeros(numOfRows, numOfColumns); %Normal H init
Ht = zeros(numOfRows, numOfColumns); %H thresholded init

for x=1:numOfRows
   for y=1:numOfColumns
       % M matrix
       M = [Gxx(x, y) Gxy(x, y); Gxy(x, y) Gyy(x, y)];
       
       % Compute the response of the detector at each pixel
       R = det(M) - parameters.k * (trace(M)^2);
       
       % Place R into (normalized) Harris Matrix
       Hdense(x, y) = R;
       
       % Create thresholded Matrix
       if (R > parameters.threshold)
           Ht(x, y) = R;
       end
       
   end
end

%Non max suppression in 3x3 space, Create Hnonmax
Hnonmax = zeros(numOfRows, numOfColumns); %Hnonmax init

for x=2:numOfRows-1
   for y=2:numOfColumns-1
       a = Ht(x,y);
       % I use this additional if statement to account for local maxima
       % that are surrounded by other local maxima with the same value (f.e.
       % in checkerboard image). These local maxima would otherwise be set
       % to 0 with a simple > comparison (vs >=), because of the way our Hdense in
       % constructed, and that would render our found corners to 0.
       if (a == 0)
            if ((a > Ht(x-1,y-1)) && (a > Ht(x-1,y)) && (a > Ht(x-1,y+1)) && (a > Ht(x,y-1)) && (a > Ht(x,y+1)) && (a > Ht(x+1,y-1)) && (a > Ht(x+1,y)) && (a > Ht(x+1,y+1)))
                Hnonmax(x,y) = 1;
            end
       else
           if ((a >= Ht(x-1,y-1)) && (a >= Ht(x-1,y)) && (a >= Ht(x-1,y+1)) && (a >= Ht(x,y-1)) && (a >= Ht(x,y+1)) && (a >= Ht(x+1,y-1)) && (a >= Ht(x+1,y)) && (a >= Ht(x+1,y+1)))
                Hnonmax(x,y) = 1;
           end
       end
   end
end


%Final Corners
H_final = Hnonmax .* Ht;
[r, c] = find(H_final);
d = H_final(H_final>0);

Corners = [r c d];

end
