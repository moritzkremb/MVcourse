function plotPointCloud(p, inliers, inlier_action)
% Plot a pointcloud
%
% If only p is passed, only the pointcloud will be plotted. With additional
% arguments, inliers will also be shown
%
% p: Pointcloud to plot (6 x N or 3 x N)
%
% inliers: Inliers to highlight or count (M x N)
%
% inlier_action: Options are count or highlight. If count is passed, the
% colour of each point will be defined by the sum of columns of inliers. A
% point which is an inlier in many of the inlier arrays will have a higher
% colour value than those which have been inliers fewer times. Highlight
% will colour all 
% 
% colour: Specifies the colour in which to plot the inliers. Or, if inliers
% and inlier_action is skipped, plot the whole cloud in the given colour

if size(p, 1) < 6 % only xyz
    colours = repmat([0 1 0], size(p, 2), 1);
else
    colours = [p(4,:)' p(5,:)' p(6,:)'];
end
    
if nargin < 2
    % only plot point cloud
    scatter3(p(1,:),p(2,:),p(3,:), [], colours, 'filled');
    set(gca,'DataAspectRatio',[1 1 1]);
    set(gca,'PlotBoxAspectRatio',[1 1 1]);
else
    if nargin < 3
        inlier_action = 'highlight';
    end
    if strcmp('count', inlier_action)
        % plot points with a colour based on the number of times they have been
        % inlier points (two colour image if there is only one set of
        % inliers)
        scatter3(p(1,:),p(2,:),p(3,:), [], sum(inliers,1), 'filled');
    elseif strcmp('highlight', inlier_action)
        hold_state = ishold;
        hold on
        
        if size(inliers, 1) > 1
            sprintf('When using the highlight inlier action inliers should be 1 x N')
        end

        scatter3(p(1,inliers),p(2,inliers),p(3,inliers), [], 'r', 'filled'); % plot inliers red
        scatter3(p(1,~inliers),p(2,~inliers),p(3,~inliers), [], colours(~inliers,:), 'filled'); % plot normal points
        if ishold ~= hold_state
            hold
        end
    end
end

rotate3d on

end