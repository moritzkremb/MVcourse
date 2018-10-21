%===================================================
% Machine Vision and Cognitive Robotics (376.054)
% Exercise 3: Object recognition with SIFT & Generalized Hough Transform
% Daniel Wolf, Michal Staniaszek 2017
% Automation & Control Institute, TU Wien
%
% Tutors: machinevision@acin.tuwien.ac.at
% This code includes parts of Andrea Vedaldi's SIFT for Matlab
%===================================================

%%%% PREPARATION %%%%
% 1. download and install Andrea Vedaldi's vlfeat library.
% http://www.vlfeat.org/download.html. See instructions at
% http://www.vlfeat.org/install-matlab.html
% 2. adjust the path to point to your vlfeat directory
run('/Users/moritzkremb/Documents/vlfeat-0.9.20/toolbox/vl_setup')
%%%%%%%%%%%%%%%%%%%%%

%%%% PARAMETERS %%%%
% index of test image to use (1-4)
image_nr = 4;
%%%%%%%%%%%%%%%%%%%%


%%%% DO NOT CHANGE REMAINDER OF FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% read image in which objects should be detected
I1C = imread(['data/image' num2str(image_nr) '.png']);
I1 = double(rgb2gray(I1C))/255.0 ;

% read template image
I2 = double(rgb2gray(imread('data/object.png')))/255.0;

% normalize intensities to range [0, 1]
I1=I1-min(I1(:));
I1=I1/max(I1(:));
I2=I2-min(I2(:));
I2=I2/max(I2(:));

fprintf('Computing frames and descriptors.\n') ;
[frames1,descr1] = vl_sift(single(I1));
[frames2,descr2] = vl_sift(single(I2));

% plot calculated SIFT descriptors
figure(1) ; clf ;
 subplot(1,2,1) ; imagesc(I1) ; colormap gray ;
 hold on ;
 h=vl_plotframe(frames1) ; set(h,'LineWidth',2,'Color','g') ;
 subplot(1,2,2) ; imagesc(I2) ; colormap gray ;
 hold on ;
 h=vl_plotframe(frames2) ; set(h,'LineWidth',2,'Color','g') ;

fprintf('Computing matches.\n') ;
% By passing to integers we greatly enhance the matching speed (we use
% the scale factor 512 as Lowe, but it could be even larger without
% overflow)
descr1=uint8(512*descr1);
descr2=uint8(512*descr2);
matches=vl_ubcmatch(descr1, descr2, 1.5);

% plot successful matches between images
figure(2); clf;
plot_matches(I1,I2,frames1, frames2, matches, 'points', 'random');

% call hough transform code to find object
[dx,dy,s,o] = detectObject(I1, I2, frames1, frames2, matches);

% plot rectangle according to found location
figure(3);
imshow(I1C); hold on;

% rectangle coordinates before transformation
[h2, w2] = size(I2);
xr = [0, w2, w2, 0, 0];
yr = [0, 0, h2, h2, 0];
p = [xr;yr];

for i=1:numel(dx)
    % transform coordinates according to rotation and translation
    tp = transformPoints(p, dx(i), dy(i), s(i), o(i));
    plot(tp(1,1:2), tp(2,1:2),'g', 'LineWidth', 3); %top
    plot(tp(1,2:3), tp(2,2:3),'b', 'LineWidth', 3); %right
    plot(tp(1,3:4), tp(2,3:4),'r', 'LineWidth', 3); %bottom
    plot(tp(1,4:5), tp(2,4:5),'m', 'LineWidth', 3); %left
end

hold off;
