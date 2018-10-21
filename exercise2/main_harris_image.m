%===================================================
% Machine Vision and Cognitive Robotics (376.054)
% Exercise 2: Interest Points and Descriptors
% Daniel Wolf, Michal Staniaszek 2017
% Automation & Control Institute, TU Wien
%
% Tutors: machinevision@acin.tuwien.ac.at
%===================================================

figure(1); clf
debug_corners = false;   % <<< change to reduce output when you're done

% read image
Igray = rgb2gray(imread('other/airplane.jpg'));

% parameters <<< try different settings!
harris.sigma1 = 0.8;
harris.sigma2 = 1.5;
harris.threshold = 0.00001;
harris.k = 0.04;

%1. Harris corner detector
[ I, Ixx, Iyy, Ixy, Gxx, Gyy, Gxy, Hdense, Hnonmax, Corners] = harris_corner(Igray, harris);

% shows detected corners
show_corners(I, Ixx, Iyy, Ixy, Gxx, Gyy, Gxy, Hdense, Hnonmax, Corners, debug_corners);
