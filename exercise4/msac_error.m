%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [error, inliers] = msac_error(~, distances, threshold)
%  purpose :    compute the MSAC error and inliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     ~:         Unused argument for compatibility with other error funcs
%     distances: Perpendicular distance of each point to the plane
%     threshold: Points with distance less than this are inliers
%  output   arguments
%     error:   MSAC error for given distances and threshold
%     inliers: logical array
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [error, inliers] = msac_error(~, distances, threshold)

% inliers
inliers = distances < threshold;

% error
er_in = sum(distances .* inliers); % inside thresh: sum distances
er_out = threshold * (size(distances, 2) - sum(inliers)); % outside: constant
error = er_in + er_out;

end