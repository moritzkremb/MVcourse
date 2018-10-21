%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function [points2] = transformPoints(points, dx, dy, scaling, rotation)                                                      
%  purpose :    Rotate, translate and scale the given points.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     points:         2xn matrix containing points with x and y coordinate
%                     in every column.
%     dx, dy:         Translation in x and y direction
%     scaling:        Scale factor
%     rotation:       Rotation angle in rad
%     
%  output   arguments
%     points2:        transformed points (same size as points)
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function points2 = transformPoints(points, dx, dy, scaling, rotation)

% variables
s = scaling;
r = rotation;
r = deg2rad(r); % back to radians

% set up transformation matrix
M = [s*cos(r), s*sin(r), dx; s*(-sin(r)), s*cos(r), dy];

% add row of ones to points matrix
points = [points; ones(1, 5)];

% calc points2
points2 = M * points;

end