%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [filtered_points, plane_eqs, plane_pts] = filterPlanes(p, min_points_prop, sac_params)
%  purpose :    filter planes from a pointcloud
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     p:               Input pointcloud (3 x N, column: [x y z]')
%     min_points_prop: If the number of points in an extracted plane is
%                      less than min_points_prop * N, return.
%     sac_params:      Parameters to use for sample consensus
%  output   arguments
%     filtered_points: Points remaining in the cloud after removing planes
%     plane_eqs:       Extracted plane equations/normals (M x 4)
%     plane_pts:       Cell array of matrices containing points filtered
%                      for each plane in plane_eqs
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [filtered_points, plane_eqs, plane_pts] = filterPlanes(points, min_points_prop, ransac_params)

% pre-process points
points(7,:) = []; % remove last row
points(:, any(isnan(points), 1)) = []; % remove NaN points
p = points;

% init values
N = size(p, 2); % nr of points
plane = 1;
points_in_plane = N;
plane_eqs = []; % matrix

filtered_points = points; % start with entire points
plane_pts = {}; % cell array


% multi plane extraction
while points_in_plane > min_points_prop * N
    
    % call ransac function
    [a,b,c,d,inliers,k] = fitPlane(p, ransac_params);
    
    % store plane values
    plane_eqs(plane, :) = [a,b,c,d];
    
    % delete inlier points of this plane
    p(:, any(inliers, 1)) = [];
    
    % update parameters
    points_in_plane = sum(inliers);
    plane = plane + 1;
end

% calculate filtered_points and plane_pts (because I can't calculate this
% in the while loop, since my p is being updated every iteration)
for i = 1:size(plane_eqs, 1)
    % plane equations
    n = plane_eqs(i,1:3);
    d = plane_eqs(i,4);
    
    % distances of points to plane
    px = points(1, 1:end)'; % Nx1
    py = points(2, 1:end)';
    pz = points(3, 1:end)';
    top = abs(n(1) .* px + n(2) .* py + n(3) .* pz + d);
    bottom = sqrt(sum(n.^2));
    distances = top'./bottom;
    
    % find the inliers of those planes
    [error, inliers] = ransac_params.error_func(points, distances, ransac_params.inlier_margin);
    
    % build filtered_points and plane_pts outputs
    rev_inliers = ~inliers;
    filtered_points = filtered_points .* rev_inliers;
    
    plane_pts(i) = {points .* rev_inliers};
end

end