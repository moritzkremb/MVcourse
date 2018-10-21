%===================================================
% Machine Vision and Cognitive Robotics (376.054)
% Exercise 1: Canny Edge Detector
% Daniel Wolf, Michal Staniaszek 2017
% Automation & Control Institute, TU Wien
%
% Tutors: machinevision@acin.tuwien.ac.at
%===================================================

% read and normalize image
img_orig = double(imread('image/lena.png'))./255.0; % try different images
img = rgb2gray(img_orig);
%img = imnoise(img,'gaussian', 0, 0.25); % add noise

%% 1. Blur image
% Use ctrl-enter to run just the selected section
sigma = 2;	% try different values
img_blurred = blur_gauss(img, sigma);

figure(1)
imshow(img_blurred);

%% 2. Edge detection
[gradients, orientations] = sobel(img_blurred);

figure(2)
%imshow(gradients);
imshow(gradients,[], 'colormap', parula);
title('gradient magnitude')
figure(3)
%imshow(orientations)
imshow(orientations,[], 'colormap', parula);
title('orientations')

% 3. Non-maxima Suppression
edges = non_max(gradients, orientations);

figure(4)
imshow(gradients - edges, [], 'colormap', parula);
title('nonmax discards')

figure(5)
imshow(edges,[], 'colormap', parula);
title('basic edges')

hyst_thresh_method = 'auto';

if strcmp(hyst_thresh_method, 'manual')
    % 4. Hysteresis Thresholding
    thresh_low = 0.1;	% change this
    thresh_high = 0.7; % change this
    canny_edges = hyst_thresh(edges, thresh_low, thresh_high);
elseif strcmp(hyst_thresh_method, 'auto')
    % 5. Automatic hysteresis thresholding
    low_prop = 0.8; % proportion values above low threshold
    high_prop = 0.4; % proportion values above high threshold
    canny_edges = hyst_thresh_auto(edges, low_prop, high_prop);
else
    error('unknown hyst_thresh_method "%s"', hyst_thresh_method)
end

figure(6)
imshow(canny_edges,[]);
title('canny edges')

figure(7)
imshow(edge_overlay(img_blurred, canny_edges))
title('edge overlay')

edge_function = edge(img, 'log');
figure(8)
imshow(edge_function,[]);
title('edge function')

%imrow('image/lena.png', 10, sigma, thresh_low, thresh_high);