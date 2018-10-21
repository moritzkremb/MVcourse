%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [clusters, point2cluster] = cluster_single(p, maxdist)
%  purpose :    cluster pointcloud to isolate objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     p:               input pointcloud (3xN, [x y z]')
%     maxdist:         Max. distance between two points of the same cluster (in meters)
%    
%  output   arguments
%     clusters:        coordinates of cluster centroids (3xC matrix, C = number of clusters)
%     point2cluster:   1xN vector, storing the assigned cluster number for each point
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [clusters, point2cluster] = cluster_single(p, maxdist)

%% Init Variables
point2cluster = 1:size(p, 2);
while_loop = 0;

% calc distances matrix with ipdm
disp("Using IPDM to calculate distances... ");
tic;
distances = ipdm(p', 'Subset', 'Maximum', 'Limit', maxdist * 1.1);
distances(distances == 0) = Inf;
toc;

%% Clustering algorithm
% I first find the min value in the distance matrix and save the 2
% associated points. Instead of deleting both rows/cols and creating a new
% one with the min distances to all other points, I replace all values of
% the lower indixed point with "Inf" and place the minimum distances into
% the higher indexed point. This is to keep the distance matrix in the same
% size and avoid losing track of the points.
while 1
    while_loop = while_loop + 1;
    fprintf("Iterations: %d\n", while_loop);
    
    % find min dist
    [m, min_i] = min(distances(:));
    
    if m > maxdist
        % finished clustering
        break;
    end
    
    % find the 2 respective points of min dist
    [p1, p2] = ind2sub(size(distances), min_i);
    
    % find the smaller&larger of the 2 points, save its row
    smaller_p = min([p1, p2]);
    larger_p = max([p1, p2]);
    to_be_deleted_col = distances(:, smaller_p);
    to_be_compared_col = distances(:, larger_p);
    
    % generate new min distances row
    min_distances = min([to_be_deleted_col, to_be_compared_col], [], 2);
    
    % replace row/col with larger index with min values
    distances(:, larger_p) = min_distances;
    distances(larger_p, :) = min_distances';
    distances(larger_p, larger_p) = Inf; % exception
    
    % replace row/col with smaller index with Inf values
    inf_col = Inf * ones(size(distances, 1), 1);
    distances(:, smaller_p) = inf_col;
    distances(smaller_p, :) = inf_col';
    
    % manage point2cluster, replace cluster nr of smaller_p with the
    % cluster nr of larger_p so that they are in the same cluster
    points_in_cluster = find(point2cluster == point2cluster(smaller_p));
    point2cluster(points_in_cluster) = point2cluster(larger_p);

end

%% Clean up point2cluster and create clusters[]
Unique = unique(point2cluster);
clusters = zeros(3, size(Unique, 2));

for i = 1:size(Unique, 2)
    % assign new ordered cluster numbers in point2cluster
    points_in_cluster = find(point2cluster == Unique(i));
    point2cluster(points_in_cluster) = i;

    % assing cluster centroids
    cluster_points_xyz = p(:, points_in_cluster);
    clusters(:, i) = mean(cluster_points_xyz, 2);
end
        
end
