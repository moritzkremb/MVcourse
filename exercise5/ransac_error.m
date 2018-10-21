%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [error, inliers] = ransac_error(~, distances, threshold)
%  purpose :    compute the RANSAC error and inliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     ~:         Unused argument for compatibility with other error funcs
%     distances: Perpendicular distance of each point to the plane
%     threshold: Points with distance less than this are inliers
%  output   arguments
%     error:   RANSAC error for given distances and threshold
%     inliers: logical array of inliers
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [error, inliers] = ransac_error(~, distances, threshold)

% inliers
inliers = distances < threshold;

% error = number of inliers
error = sum(inliers);

end