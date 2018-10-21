%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [a,b,c,d,inliers,k] = fitPlane(p, params)
%  purpose :    find dominant plane in pointcloud with sample consensus
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     p:                      input pointcloud (3 x N, column: [x y z]')
%     params: parameters for the sample consensus
%     params.confidence:      solution confidence in percent, range [0, 1)
%     params.inlier_margin:   Max. distance of a point from the plane to be considered an inlier (in meters)
%     params.min_sample_dist: Min. distance of all sampled points to each other (in meters).
%     params.error_func:      Function to use when computing inlier error
%  output   arguments
%     a,b,c,d:         plane parameters
%     inliers:         logical array marking the inliers of the pointcloud
%     k:			   number of iterations needed
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [a,b,c,d,inliers,k] = fitPlane(p, params)

% init values
best_error = 0;
best_n = 0;
best_d = 0;

m = 3; % model
k = 0; % iterations needed
N = size(p, 2); % nr of points

e = m/N; % inital value: model/Nr. of points
confidence = (1-e^m)^k;

% Ransac algorithm

while confidence >= params.confidence
    
    % min_sample_dist
    too_close = 1;
    while too_close        
        % randomly select 3 points
        r = randperm(N,3); % 3 random nrs

        % get points
        p1 = p(:,r(1)); % 6x1 vector
        p1(4:6) = []; % remove, 3x1 vector containing x,y,z

        p2 = p(:,r(2));
        p2(4:6) = [];

        p3 = p(:,r(3));
        p3(4:6) = [];
        
        % calc distances between points
        d12 = p1-p2;
        d12 = sqrt(sum(d12.^2));
        
        d13 = p1-p3;
        d13 = sqrt(sum(d13.^2));
        
        d23 = p2-p3;
        d23 = sqrt(sum(d23.^2));
        
        t = params.min_sample_dist;
        if (d12 < t || d13 < t || d23 < t)
            too_close = 1; % find new points
        else
            too_close = 0; % break
        end
    end
    
    % build plane based on these 3 points
    nx = p1-p2;
    ny = p1-p3;
    n = cross(nx', ny');
    d = -n * p1;
    
    % calculate distances of points to this plane
    px = p(1, 1:end)'; % Nx1
    py = p(2, 1:end)';
    pz = p(3, 1:end)';
    top = abs(n(1) .* px + n(2) .* py + n(3) .* pz + d);
    bottom = sqrt(sum(n.^2));
    distances = top'./bottom;
    
    % call error function
    [error, inliers] = params.error_func(p, distances, params.inlier_margin);
    
    if (error > best_error)
        % update parameters
        best_error = error;
        e = error/N;
        % set this model as best model so far
        best_n = n;
        best_d = d;
    end
    
    % count iterations
    k = k + 1;
    
    % update confidence
    confidence = (1-e^m)^k;
end

% preliminary best model

a = best_n(1);
b = best_n(2);
c = best_n(3);
d = best_d;

% refine the fit

M = p .* inliers; % zero out the outliers
M(4:6,:) = []; % remove rgb rows
M(4,:) = 1; % place d = 1 for all
[U, S, V] = svds(M); % svd takes way too long

a = U(1,4);
b = U(2,4);
c = U(3,4);
d = U(4,4);

end