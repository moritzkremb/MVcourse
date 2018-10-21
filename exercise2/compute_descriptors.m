%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  [interest_points, descriptors] = compute_descriptors(descriptor_func, img, locations, psize)
%  purpose: Calculate the given descriptor on patches of size psize x psize 
%           of the image, centred on the locations provided
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     descriptor_func: Descriptor to compute at each location
%     img:             Input grayscale image, value range: 0-1
%     locations:       locations at which to compute the descriptors (n x 2)
%                      First column is y, second is x.
%     psize:           Scalar value defining the width and height of the
%                      patch around each location to pass to the descriptor
%                      function.
%
%  output   arguments
%     interest_points: k x 2 matrix containing the image coordinates [y,x]
%                     of the corners. Locations too close to the image
%                     boundary to cut out the image patch should not be
%                     included.
%     descriptors:    k x m matrix containing the patch descriptors, where
%                     m is the length of the descriptor returned by
%                     descriptor_func (which may vary).
%                     Each row is a single descriptor.
%                     Descriptors at locations too close to the image 
%                     boundary to cut out the image patch should not be
%                     included. 
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [interest_points, descriptors] = compute_descriptors(descriptor_func, img, locations, psize)


% 1. Calculate relevant interest points

all_locations = locations;
img_rows = size(img, 1); % pixels in y direction
img_columns = size(img, 2); % pixels in x direction
dst_from_border = floor(psize/2); % f.e. if psize is 5 we need distance 2

% find points where y is too close to border of image and remove those rows
interim_IP = all_locations; %define a Interim Interest Points to carry along

y = all_locations(:, 1);
y_indices_low = find(y <= dst_from_border); % locations below threshold

interim_IP = removerows(interim_IP, 'ind', y_indices_low); % remove them

y = interim_IP(:, 1); % new y with low points removed
y_indices_high = find(y >= (img_rows - dst_from_border)); % locations above threhold

interim_IP = removerows(interim_IP, 'ind', y_indices_high); % remove them

% find points where x is too close to border of image amd remove that row
x = interim_IP(:, 2); % everything same as above
x_indices_low = find(x <= dst_from_border);

interim_IP = removerows(interim_IP, 'ind', x_indices_low);

x = interim_IP(:, 2);
x_indices_high = find(x >= (img_columns - dst_from_border));

interim_IP = removerows(interim_IP, 'ind', x_indices_high);

% Final interest points

interest_points = interim_IP;


% 2. Calculate descriptors

nr_of_IP = size(interest_points, 1);

descriptors = zeros(nr_of_IP, psize^2); % put 128 instead of psize^2 in case of block_orientation
% since block orientation is not a square matrix.

k = dst_from_border; % coz names matter

for i = 1:nr_of_IP
    r = interest_points(i,1); % row of interest point
    c = interest_points(i,2); % column of interest point
    
    % coordinates for rectangle around IP
    rmin = r - k;
    cmin = c - k; 
    rect = [cmin rmin psize-1 psize-1];
    
    % crop patch around IP
    patch = imcrop(img, rect);

    % use descriptor_func and assign resulting vector to descriptors
    descriptors(i, :) = descriptor_func(patch);
    
end

end