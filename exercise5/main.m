%===================================================
% Machine Vision and Cognitive Robotics (376.054)
% Exercise 5: Clustering
% Daniel Wolf, Michal Staniaszek 2017
% Automation & Control Institute, TU Wien
%
% Tutors: machinevision@acin.tuwien.ac.at
%
% MAIN SCRIPT - DO NOT CHANGE CODE EXCEPT FOR THE PARAMETER SETTINGS
%===================================================

%%%%%%%% SELECT POINTCLOUD FILE %%%%%%%%
pointcloud_idx = 9;            % 0-9
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%% CHANGE RANSAC PARAMETERS HERE %%%%
sac_params.inlier_threshold = 0.02;      % in meters
sac_params.min_sample_dist = 0.1;     % in meters
sac_params.confidence = 0.99;
sac_params.error_func = @msac_error;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%% CHANGE CLUSTERING PARAMETERS HERE %%
% proportion of the cloud remaining after plane removal to use for clustering
downsample_prop = 0.1;
maxdist = 0.03;           % in meters
clustering_alg = 'kdtree'; % single, kdtree or kdtree-norm
ang_thresh = 1.2; % threshold on angle to consider normals as part of the same cluster
normal_estimation_points = 30; % number of neighbours to consider when estimating normal at each point
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

apply_ransac = false; % for some clouds you may wish not to apply ransac
use_builtin = true; % use matlab's builtin ransac

%% Set up cloud

pc_fname = sprintf('pointclouds/image%03d.pcd',pointcloud_idx);
%pc_fname = 'pointclouds/kitchen.pcd';

% load point cloud from file
p_orig = pcread(pc_fname);
% Remove NaN and Inf points
p = p_orig.removeInvalidPoints();
% Remove [0 0 0] points
p = p.select(find(all(p.Location ~= [0 0 0], 2)));

%% Part 1: SAC

if apply_ransac
    figure(1);
    pcshow(p)

    fprintf(1,'Trying to fit a plane with RANSAC...\n');

    h=tic;
    if use_builtin
        [model, inliers, ~] = pcfitplane(p, sac_params.inlier_threshold);
        
        % convert inliers to logical array for consitency
        if isa(inliers, 'double')
            tmp_inliers = zeros(1, p.Count);
            tmp_inliers(inliers) = 1;
            inliers = logical(tmp_inliers);
        end

        a = model.Parameters(1);
        b = model.Parameters(2);
        c = model.Parameters(3);
        d = model.Parameters(4);
    else
        % Calling your function
        [a,b,c,d,inliers,sample_count] = fitPlane(double(p.Location'), sac_params);
        fprintf(1, 'DONE. %d iterations needed.\n', sample_count);
        toc(h)
    end
    
    figure(2);
    plotPointCloud(p, inliers);

    % remove all points of the plane
    p_filtered = select(p, find(~inliers));
else
    p_filtered = p;
end

% subsample the filtered points
psub = select(p_filtered, randperm(p_filtered.Count, round(p_filtered.Count * downsample_prop)));

%% Part 2: clustering
fprintf(1,'Clustering...\n');
g = tic;
% Calling your function
if strcmp(clustering_alg, 'single')
    [clusters, point2cluster] = cluster_single(psub.Location', maxdist);
elseif strcmp(clustering_alg, 'kdtree')
    [clusters, point2cluster] = cluster_kdtree(psub.Location', maxdist);
elseif strcmp(clustering_alg, 'kdtree-norm')
    normals = getNormals(psub, normal_estimation_points);
    showCloudWithNormals(psub, normals);
    [clusters, point2cluster] = cluster_kdtree_norm(psub.Location', normals', maxdist, ang_thresh);
else
    fprintf(1, 'Unknown clustering algorithm %s', clustering_alg);
end
toc(g)

fprintf(1,'DONE. %d clusters found.\n', size(clusters,2));

figure(3);
plotClusteringResult(psub, clusters, point2cluster);
title(sprintf('Pointcloud %d', pointcloud_idx));
