%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  edges = hyst_thres(edges_in, low, high)
%  purpose :    hysteresis thresholding
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     edges_in:    edge image (m x n)
%     low:  lower hysteresis threshold
%     high: higher hysteresis threshold
%  output   arguments
%     edges:     edge image with hysteresis thresholding applied (m x n)
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edges = hyst_thresh(edges_in, low, high)

% normalize gradient
n_edges = edges_in/max(edges_in(:));

% Threshholding with find and bwselect

[aboveHigh_r, aboveHigh_c] = find(n_edges > high);  % Row and column 
% coordinates of pixels above upper threshold.

aboveLow = n_edges > low; % All edge pixels above lower threshold                                     
					   
edges = bwselect(aboveLow, aboveHigh_c, aboveHigh_r, 8);
% Pixels in aboveLow that are connected to pixels in aboveHigh

end