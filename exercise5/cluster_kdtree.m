    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     p:               input pointcloud (3xN)
%     maxdist:         Max. distace between two points of the same cluster (in meters)
%    
%  output   arguments
%     clusters:        coordinates of cluster centroids (3xC matrix, C = number of clusters)
%     point2cluster:   1xN vector, storing the assigned cluster number for each point
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [clusters, point2cluster] = cluster_kdtree(p, maxdist)

%% Init Variables
point2cluster = zeros(1, size(p, 2)); %1xN
clusters = [];
points = p'; % Nx3
while_loop = 0;
cl_count = 1;
MdlKDT = KDTreeSearcher(points); % set up kdtree model

%% Kdtree algorithm
while 1
    while_loop = while_loop + 1;
    fprintf("Iterations: %d\n", while_loop);
    
    % check if p is empty, then exit (when there is no more 0 in point2cluster)
    if ~ismember(0, point2cluster)
        % finished clustering
        break;
    end
    
    % get some p that is available (=not yet clustered)
    available_points = 1:size(points, 1);
    taken_points = find(point2cluster); % taken points are non-zero in point2cluster
    available_points(taken_points) = 0; % available points are non-zero
    while 1
        starting_point = randsample(size(points, 1), 1); % ind of a random point
        if available_points(starting_point) ~= 0
            % if the point is not 0 then proceed with this point
            break;
        end
    end
                
    % set up initial points for kdtree search
    all_rn_ind = starting_point; %nx3
    previous_rn_ind = [];
    
    % search in tree for all neighbours, then feed the found points back
    % into the search
    while 1
        % stop if found points dont change anymore
        if isequal(all_rn_ind, previous_rn_ind)
            break;
        end
        previous_rn_ind = all_rn_ind; % save previous list for comparison
        
        % range search within maxdist
        rn_points = points(all_rn_ind, :);
        rn_kdT = rangesearch(MdlKDT, rn_points, maxdist);
        all_rn_ind = [];
        for i = 1:size(rn_kdT, 1)
            % add all the found points together into one big array
            rn_ind = rn_kdT{i};
            all_rn_ind = [all_rn_ind, rn_ind];
        end
        
        % use this code for knnsearch instead of rangesearch (see doc)
        % all_rn_ind = knnsearch(MdlKDT, rn_points, 'k', 50);

        % clear the array of duplicates
        all_rn_ind = unique(all_rn_ind);
                
    end
    
    % all points in cluster have been found, now add to point2cluster and clusters
    point2cluster(all_rn_ind) = cl_count;
    
    cluster_points = p(:, all_rn_ind);
    clusters(:, cl_count) = mean(cluster_points, 2);
    
    cl_count = cl_count + 1;

end

end