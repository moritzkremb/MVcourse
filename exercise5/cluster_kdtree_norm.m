%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [clusters, point2cluster] = cluster_kdtree_norm(p, normals, neighbour_radius, ang_thresh)
%  purpose :    cluster pointcloud to isolate objects, using kdtree and
%  normals
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     p:        input pointcloud (3xN, [x y z]')
%     normals:  Normal vector at each point (3xN, [x y z]')     
%     neighbour_radius: Radius within which points are considered to be
%                       neighbours
%     ang_thresh:       Points with normals which have a relative angular
%                       distance of less than this are considered neighbours
%    
%  output   arguments
%     clusters:        coordinates of cluster centroids (3xC matrix, C = number of clusters)
%     point2cluster:   1xN vector, storing the assigned cluster number for each point
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [clusters, point2cluster] = cluster_kdtree_norm(p, normals, neighbour_radius, ang_thresh)

%% Init variables
point2cluster = zeros(1, size(p, 2)); %1xN
clusters = [];
points = p'; % Nx3
normals = normals'; %Nx3
while_loop = 0;
cl_count = 1;
MdlKDT = KDTreeSearcher(points); % create kd model

%% kdtree-norm algorithm
% same as kdtree, but after points in cluster found, the points with
% different normals are substracted
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
    taken_points = find(point2cluster);
    available_points(taken_points) = 0;
    while 1
        starting_point = randsample(size(points, 1), 1);
        if available_points(starting_point) ~= 0
            break;
        end
    end
                
    % set up initial points for kdtree search  
    all_rn_ind = starting_point;
    previous_rn_ind = [];
    
    % search in tree for all neighbours, then feed the found points back
    % into the search
    while 1
        % stop if list doesnt change anymore
        if isequal(all_rn_ind, previous_rn_ind)
            break;
        end
        previous_rn_ind = all_rn_ind; % save previous list
        
        % range search
        rn_points = points(all_rn_ind, :);
        rn_kdT = rangesearch(MdlKDT, rn_points, neighbour_radius);
        all_rn_ind = [];
        for i = 1:size(rn_kdT, 1)
            rn_ind = rn_kdT{i};
            all_rn_ind = [all_rn_ind, rn_ind];
        end
        all_rn_ind = unique(all_rn_ind);
                
    end
    
    % Compare normals and remove points from cluster if normals not in
    % range
    
    % I tried to do this using kdtree but it didnt work
    %cl_normals = normals(all_rn_ind, :);
    %MdlKDT1 = ExhaustiveSearcher(cl_normals);
    %MdlKDT1.Distance = 'cosine';
    %normals_kdT = rangesearch(MdlKDT1, normals(starting_point, :), ang_thresh);
    %all_rn_ind = normals_kdT{1};
    
    % probably slower version using compare in a for loop. The normal of
    % the starting point is chosen and compared against other points in the
    % cluster
    compare_norm = normals(starting_point, :); % normal used to compare
    cl_normals = normals(all_rn_ind, :);
    
    for i = 1:size(cl_normals, 1)
        % calculate angle difference
        a = compare_norm;
        b = cl_normals(i, :);
        angle = atan2(norm(cross(a,b)), dot(a,b));
        
        % if angle difference above thresh, set to 0
        if angle > ang_thresh
            all_rn_ind(i) = 0;
        end
    end
    
    all_rn_ind = all_rn_ind(all_rn_ind > 0); % remove points that are 0
    
    
    % finally add to point2cluster and create cluster centroids
    point2cluster(all_rn_ind) = cl_count;
    
    cluster_points = p(:, all_rn_ind);
    clusters(:, cl_count) = mean(cluster_points, 2);
    
    cl_count = cl_count + 1;

end

end