%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  edges = hyst_thresh_auto(edges_in, low_prop, high_prop)
%  purpose: hysteresis thresholding with automatic threshold selection
%  based on proportion of edge pixels to be found above high and low
%  thresholds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input arguments
%     edges_in: edge image (m x n)
%     low_prop: proportion of edge pixels in the image that should be found
%               above the low threshold
%     high_prop:  proportion of edge pixels in the image that should be
%                 found above the high threshold
%  output arguments
%     edges: binary edge image with hysteresis thresholding applied, where
%            thresholds have been automatically selected based on edge
%            pixel values (m x n)
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edges = hyst_thresh_auto(edges_in, low_prop, high_prop)

% The exercise says "We will assume that some proportion of edge pixels 
% should be above the high threshold, and some proportion above the low 
% threshold. So I don't see why we need to use histogram. The following
% method is IMO much simpler. (Unless the phrasing was slightly misleading
% and I understood the question wrong)

% normalize edges
n_edges = edges_in/max(edges_in(:));

% remove all zero values
A = n_edges(n_edges > 0);

sz_of_A = size(A,1); % size of A
sorted_A = sort(A); % sorted A

% find points where low_thresh and high_thresh are in sorted_A based on
% proportions
point1 = round((1-low_prop) * sz_of_A);
if (point1 < 1)
    point1 = 1;
end

point2 = round((1-high_prop) * sz_of_A);
if (point2 > sz_of_A)
    point2 = sz_of_A;
end

low = sorted_A(point1);
high = sorted_A(point2);

% do thresholding
edges = hyst_thresh(edges_in, low, high);

end