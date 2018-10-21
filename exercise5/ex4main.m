%===================================================
% Machine Vision and Cognitive Robotics (376.054)
% Exercise 4: Plane fit with RANSAC
% Daniel Wolf, Michal Staniaszek 2017
% Automation & Control Institute, TU Wien
%
% Tutors: machinevision@acin.tuwien.ac.at
%
% MAIN SCRIPT - DO NOT CHANGE CODE EXCEPT FOR THE PARAMETER SETTINGS
%===================================================

%%%%% CHANGE SAC PARAMETERS HERE %%%%
sac_params.inlier_margin = 0.01;      % in meters
sac_params.min_sample_dist = 0.001;    % in meters
sac_params.confidence = 0.8;
sac_params.error_func = @ransac_error; % function to use to compute error and inliers

reduced_cloud_points = 30000; % use to reduce the number of points in the cloud

pointcloud_idx = 1;            % 0-9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% path to load pcd file function
addpath matpcl;

% load point cloud from file

p = double(loadpcd(sprintf('pointclouds/image%03d.pcd',pointcloud_idx)));
% rearrange point cloud
p = reshape(p, size(p,1)*size(p,2),size(p,3))';
% delete all [0;0;0] entries
idx = (all(p(1:3,:) == zeros(3,size(p,2))));
p = p(:,~idx);

p = p(:, randi([ 1 size(p,2)], [1 reduced_cloud_points]));

figure(1);
plotPointCloud(p);
title(sprintf('Pointcloud %d', pointcloud_idx));

sprintf('Trying to fit a plane with RANSAC...\n');

h=tic;
% Calling your function
[a,b,c,d,inliers,sample_count] = fitPlane(p, sac_params);
toc(h)

sprintf('DONE. %d iterations needed.\n', sample_count);

figure(2);
plotPointCloud(p, inliers);
title(sprintf('Pointcloud %d', pointcloud_idx));

%% multi-plane extraction
% load point cloud from file
% desk/kitchen/door will load as XYZRGBA, you can ignore the A component -
% it is always 1.
p = double(loadpcd('pointclouds/door.pcd'));
% rearrange point cloud
p = reshape(p, size(p,1)*size(p,2),size(p,3))';
% delete all [0;0;0] entries
idx = (all(p(1:3,:) == zeros(3,size(p,2))));
p = p(:,~idx);
p = p(:, randi([ 1 size(p,2)], [1 reduced_cloud_points]));

min_points_prop = 0.01; % change this

[filtered, eqs, planepts] = filterPlanes(p, min_points_prop, sac_params);

figure
plotPointCloud(filtered)

colours = hsv(size(eqs,1)); % Colour each extracted plane differently
for plane_ind = 1:size(eqs,1)
   plane_mat = planepts{plane_ind};
   plane_mat(4:6, :) = repmat(colours(plane_ind, :)', 1, size(plane_mat, 2));
   hold on
   plotPointCloud(plane_mat);
end