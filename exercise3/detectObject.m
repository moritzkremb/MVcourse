%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function [x,y,s,o] = detectObject(test_image, object_image, frames1, frames2, matches)                                                         
%  purpose :    Detect multiple object instances using the Hough transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     test_image:     Image in which the object should be detected
%     object_image:   Image of object to detect. (Image dimensions might be
%                     useful to set x/y grid size)
%     frames1/2:      4xn matrix containing the geometric properties of the
%                     SIFT descriptors of image1 and image2. 
%                     Row 1: x coordinate
%                     Row 2: y coordinate
%                     Row 3: Scale
%                     Row 4: Orientation
%                     ATTENTION: Because the y-coordinate points down, 
%                     "clockwise" is the positive angle direction!                   
%     matches:        2xm matrix storing the indices of matched descriptors
%                     of image 1 and 2 (each column corresponds to 1 match).
%     
%  output   arguments
%     x, y:           x- and y-coordinate of the top-left corner of the
%                     found object (in image coordinates)
%     s:              Scale of the found object with respect to object image 
%     o:              Orientation of the found object
%                     ATTENTION: Because the y-coordinate points down,
%                     "clockwise" is the positive angle direction!
%     All output arguments should be vectors containing as many elements as
%     detected object instances. Thus, x(1), y(1), s(1) and o(1) contain
%     the configuration of the first detected instance, x(2), y(2), s(2) and 
%     o(2) the second and so on...
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [x,y,s,o] = detectObject(test_image, object_image, frames1, frames2, matches)

%% Set up voting space X,Y,S,O

% set discretization parameters
param_x = 10; % multiplier, x (nr of bins)
param_y = 10; % multiplier, y (nr of bins)
param_s = 10; % multiplier, scale (1/param_s is bin width)
param_o = 3; % orientation, (bin width in degrees)

% set extraction parameters
param_t = 2; % threshold for peak detection [nr of votes]
% another implementation with larger files could use percentage, but here
% this works better

% x
obj_img_r_x = ceil(size(test_image, 2) / size(object_image, 2)); % object image ratio
size_x = param_x * obj_img_r_x; % nr of bins in x direction
bin_x = size(test_image, 2) / size_x; % bin width

% y
obj_img_r_y = ceil(size(test_image, 1) / size(object_image, 1));
size_y = param_y * obj_img_r_y;
bin_y = size(test_image, 1) / size_y;

% scale
f1_max = max(frames1, [], 2); % max of test image
f2_min = min(frames2, [], 2); % max of object
obj_img_r_s = ceil(f1_max(3, 1) / f2_min(3, 1)); % max/min to avoid overbound
size_s = param_s * obj_img_r_s;
bin_s = 1/param_s; % we need precise steps here

% orientation
bin_o = param_o;
size_o = 360/param_o;

% Hough space
Hs = zeros(size_y, size_x, size_s, size_o);
Hs_xy = zeros(size_y, size_x);

% for debugging
X = zeros(size_x, 1);
Y = zeros(size_y, 1);
S = zeros(size_s, 1);
O = zeros(size_o, 1);

%% For each match, add a vote for the corresponding (x,y,s,o) configuration in the voting space

for i = 1:size(matches, 2)
    
    % extract values from frames 1 & 2
    ind = matches(:, i);
    
    x1 = frames1(1, ind(1));
    y1 = frames1(2, ind(1));
    s1 = frames1(3, ind(1));
    o1 = frames1(4, ind(1));
    
    x2 = frames2(1, ind(2));
    y2 = frames2(2, ind(2));
    s2 = frames2(3, ind(2));
    o2 = frames2(4, ind(2));
    
    % convert angles to standard degrees for simplicity [-270, 90] to [0, 360]
    if (o1 >= 0 && o1 <= pi/2)
        o1 = 270 - (o1/(2*pi)) * 360;
    elseif (o1 < 0 && o1 > -pi/2)
        o1 = 270 - (o1/(2*pi)) * 360;
    elseif (o1 <= -pi/2 && o1 > -pi)
        o1 = -(o1/(2*pi) * 360) - 90;
    elseif (o1 <= -pi && o1 >= -1.5*pi)
        o1 = -(o1/(2*pi) * 360) - 90;
    end
    
    if (o2 >= 0 && o2 <= pi/2)
        o2 = 270 - (o2/(2*pi)) * 360;
    elseif (o2 < 0 && o2 > -pi/2)
        o2 = 270 - (o2/(2*pi)) * 360;
    elseif (o2 <= -pi/2 && o2 > -pi)
        o2 = -(o2/(2*pi) * 360) - 90;
    elseif (o2 <= -pi && o2 >= -1.5*pi)
        o2 = -(o2/(2*pi) * 360) - 90;
    end
    
    % now on to calculate dx, dy
    % map object onto image and scale to right size
    xn = (s1/s2) * x2; % scaled x and y
    yn = (s1/s2) * y2;
    r = sqrt(xn^2 + yn^2); % radius
    theta = rad2deg(asin(yn/r)); % angle within object [in degrees]
    
    % now shift the object into the right orientation
    nu = o1 - o2; % difference of orientation, amount to be shifted [in degrees]
    if (nu < 0) % if negative, rotate around the other direction (always anti-clockwise)
        nu = 360 + nu;
    end
    
    rho = theta - nu; % angle after shifting the object [in degrees]
    
    if (rho <= 90 && rho >= 0) % point is in 2nd quadrant
        tau = deg2rad(rho);
        xd = r * cos(tau);
        yd = r * sin(tau);
        dx = x1 - xd;
        dy = y1 - yd;
    elseif (rho < 0 && rho >= -90) % 3rd
        tau = deg2rad(90 + rho);
        xd = r * sin(tau);
        yd = r * cos(tau);
        dx = x1 - xd;
        dy = y1 + yd;
    elseif (rho < -90 && rho >= -180) % 4th
        tau = deg2rad(180 + rho);
        xd = r * cos(tau);
        yd = r * sin(tau);
        dx = x1 + xd;
        dy = y1 + yd;
    elseif (rho < -180 && rho >= -270 ) %1st
        tau = deg2rad(270 + rho);
        xd = r * sin(tau);
        yd = r * cos(tau);
        dx = x1 + xd;
        dy = y1 - yd;
    elseif (rho < -270 && rho >= -360) % 2nd quadrant
        tau = deg2rad(360 + rho);
        xd = r * cos(tau);
        yd = r * sin(tau);
        dx = x1 - xd;
        dy = y1 - yd;
    end
    
    % add dx, dy, alpha, s to voting space
    % if they are outside, its wrong match or object not fully in image
    if (dx >= 0 && dy >= 0 && dx <= size(test_image, 2) && dy <= size(test_image, 1))
        % location
        bin_pos_x = ceil(dx/bin_x);
        bin_pos_y = ceil(dy/bin_y);       
        
        % scale (with respect to object)
        bin_pos_s = ceil((s1/s2)/bin_s);
        
        % angle alpha (is equal to amount of shift)
        bin_pos_o = ceil(nu/bin_o);
        
        % add to hough space
        Hs(bin_pos_y, bin_pos_x, bin_pos_s, bin_pos_o) = Hs(bin_pos_y, bin_pos_x, bin_pos_s, bin_pos_o) + 1;
        Hs_xy(bin_pos_y, bin_pos_x) = Hs_xy(bin_pos_y, bin_pos_x) + 1;

        % debugging
        X(bin_pos_x) = X(bin_pos_x) + 1; 
        Y(bin_pos_y) = Y(bin_pos_y) + 1; 
        S(bin_pos_s) = S(bin_pos_s) + 1; 
        O(bin_pos_o) = O(bin_pos_o) + 1;
    end
    
end

%% Detect peaks in the voting space and return the (x,y,s,o) configuration for each peak
% This method will try to reduce the bounding boxes down to 1 for each object

% 1. Local Non-max algorithm on Hs_xy (Its sufficient and more efficient to check
% within the Hs_xy matrix, since we are interested in the locations first)

Hnonmax = zeros(size_y+2, size_x+2); % Hnonmax init

% Expand Hs_xy with zeros around it
Hse_xy = Hs_xy;
expand_row = zeros(size_y, 1); 
expand_col = zeros(1, size_x+2);
Hse_xy = [expand_row, Hse_xy, expand_row];
Hse_xy = [expand_col; Hse_xy; expand_col];

% 3x3 non-max process
for x=2:size(Hse_xy, 1)-1
   for y=2:size(Hse_xy, 2)-1
       a = Hse_xy(x,y);
       if ((a >= Hse_xy(x-1,y-1)) && (a >= Hse_xy(x-1,y)) && (a >= Hse_xy(x-1,y+1)) && (a >= Hse_xy(x,y-1)) && (a >= Hse_xy(x,y+1)) && (a >= Hse_xy(x+1,y-1)) && (a >= Hse_xy(x+1,y)) && (a >= Hse_xy(x+1,y+1)))
             Hnonmax(x,y) = a;
       end
   end
end

% revert nonmax back to correct size
Hnonmax(size(Hnonmax, 1), :) = []; % delete last row
Hnonmax(:, size(Hnonmax, 2)) = []; % delete last col
Hnonmax(1, :) = []; % delete 1st row
Hnonmax(:, 1) = []; % delete 1st col

% 2. Thresholding

% thresholding based on percentage, but i found hard-coded works better here
% H_max = max(max(Hnonmax)); % get max value
% thresh = param_t/100 * H_max; % set the threshold

% hard-coded threshold (set above in parameters)
thresh = param_t;
Ht = Hnonmax.*(Hnonmax>thresh); % create thresholded matrix Ht

[ind_r, ind_c] = find(Ht); % Extract indices of non-zero location values

% 3. Find corresponding max values of s, o
[x, y, s, o] = deal(zeros(size(ind_r, 1), 1)); % init

for k = 1:size(ind_r, 1)
    % get s
    [s_count, s_ind] = max(Hs(ind_r(k), ind_c(k), :));
    [s_row, s_col] = ind2sub([size_s, size_o], s_ind);
    
    % get o
    [o_count, o_ind] = max(Hs(ind_r(k), ind_c(k), s_row, :));
    
    % create vectors
    x(k) = ind_c(k) * bin_x - bin_x/2; % take middle value of bins
    y(k) = ind_r(k) * bin_y - bin_y/2;
    s(k) = s_row * bin_s - bin_s/2;
    o(k) = o_ind * bin_o - bin_o/2; % this is in degrees!

end

end