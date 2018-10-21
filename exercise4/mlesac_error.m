%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [error, inliers] = ransac_error(points, distances, threshold)
%  purpose :    compute the MLESAC error and inliers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     points:    Points in the cloud
%     distances: Perpendicular distance of each point to the plane
%     threshold: Points with distance less than this are inliers
%  output   arguments
%     error:   MLESAC error for given distances and threshold
%     inliers: logical array of inliers
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [error, inliers] = mlesac_error(points, distances, threshold)

% inliers
Y = normpdf(distances, threshold, 1);
inliers = distances - Y;

% it was not clear to me what to do here
error = 100;

end