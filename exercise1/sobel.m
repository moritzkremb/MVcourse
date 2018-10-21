%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [gradient, orientation] = sobel(img)
%  purpose :  Computes the gradient and the orientation of an image with
%  the sobel operator
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     img:    grayscale input image (m x n)
%  output   arguments
%     gradient:     gradients image (m x n)
%     orientation:  orientation image (m x n)
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [gradient, orientation] = sobel(img)

% Create 3 by 3 sobel kernel
h = fspecial('sobel');

% Create arrays with Edge strength and angles
Gy = imfilter(img, h, 'conv','replicate'); %points in y direction (up)
Gx = imfilter(img, h', 'conv', 'replicate'); %points in -x direction (left)
G = sqrt(Gx.^2 + Gy.^2);
angle = atan(Gy./Gx)*180/pi; %function gives values [-pi/2, pi/2], convert 
%to degrees for easier use.
%Due to the orientation of Gx and Gy the angle will be positive for
%gradients in 2nd and 4th quadrant and negative for 1st and 3rd quadrant.
%This will be important for the suppression step.

gradient = G;
orientation = angle;

end