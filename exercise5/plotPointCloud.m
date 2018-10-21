%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Machine Vision and Cognitive Robotics WS 2013 - Exercise 4
% HELPER FUNCTION TO DISPLAY POINT CLOUDS AND A FITTED PLANE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function plotPointCloud(p, inliers, inlier_action)

if size(p, 1) < 6 % only xyz
    colours = repmat([0 1 0], size(p, 2), 1);
else
    colours = [p(4,:)' p(5,:)' p(6,:)'];
end

if isa(p, 'pointCloud')
    if nargin < 2
        pcshow(p)
    else
        pcoloured = copy(p);
        pcoloured.Color(inliers, :) = repmat([0 255 0], numel(find(inliers)), 1);
        pcoloured.Color(~inliers, :) = repmat([255 0 0], numel(find(~inliers)), 1);
        pcshow(pcoloured)
    end
else
    if nargin < 2
        % only plot point cloud
        plot3(p(1,:),p(2,:),p(3,:),'b.');
    else
        % plot inliers and outliers
        plot3(p(1,find(inliers)),p(2,find(inliers)),p(3,find(inliers)),'g.');
        hold on;
        plot3(p(1,find(~inliers)),p(2,find(~inliers)),p(3,find(~inliers)),'r.');

        % plot fitted plane as mesh
        padding = 0.2;

        pi = p(1:2,inliers);
        mins = min(pi,[],2);
        maxs = max(pi,[],2);

        rangex = mins(1)-padding:0.05:maxs(1)+padding;
        rangey = mins(2)-padding:0.05:maxs(2)+padding;
        [x y] = meshgrid(rangex, rangey);
        z = (-a*x -b*y-d)/c;
        mesh(x,y,z,'EdgeColor',[0 0 1])
        rotate3d on
        hold off;       
    end
end