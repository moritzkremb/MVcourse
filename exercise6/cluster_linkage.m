%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [clusters, point2cluster] = cluster_single(p, maxdist)
%  purpose :    cluster pointcloud to isolate objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     p:               input pointcloud (Nx3, [x y z])
%     maxdist:         Max. distance between two points of the same cluster (in meters)
%    
%  output   arguments
%     clusters:        coordinates of cluster centroids (3xC matrix, C = number of clusters)
%     point2cluster:   1xN vector, storing the assigned cluster number for each point
%
%   Author:
%   MatrNr:
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [clusters, point2cluster] = cluster_linkage(p, cutoff, depth)

% these parameters give reasonable results for the object-on-floor set
if nargin < 2
    cutoff = 3;
end

if nargin < 3
    depth = 6;
end
    
linkages = linkage(p, 'single', 'euclidean');
point2cluster = cluster(linkages, 'cutoff', cutoff, 'depth', depth);

clusters = zeros(numel(unique(point2cluster)), 3);

for i=unique(point2cluster)'
    clusters(i,:) = mean(p(point2cluster == i, :));
end

clusters = clusters';

end