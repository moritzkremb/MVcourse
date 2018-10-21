%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  edges = non_max(gradients, orientations)
%  purpose: computes non-maximum suppression
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input arguments
%     gradients:    gradient image (m x n)
%     orientations: orientation image (m x n)
%  output arguments
%     edges: edge image from gradients with non-edge pixels set to zero,
%            retaining gradient magnitude. (m x n)
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edges = non_max(gradients, orientations)
 
% We will create 2 for loops to iterate across our gradients image.

[r, c] = size(gradients); %size
edges = zeros(r,c); %init

for i = 2:r-1  % rows, we leave out first and last pixels

    for j = 2:c-1 % columns
       
      % Within the loop we need to separate the problem into 4 parts,
      % depending on the angle, in order to calculate the
      % interpolations D1 and D2. Note that the angles are
      % transformed, due to the orientation of Gx and Gy.
      % We then compare the gradient with D1 and
      % D2 and set gradient to 0 if smaller.
      
      % Part 1: Angles 0° - 45° (Actual angle: 0° - -45°)        
      if ((orientations(i,j) >= 0) && (orientations(i,j) <= 45))
          angle = orientations(i,j);
          nx = 1 * tan(angle*pi/180); % length of the opposite in a unit circle
          ny = 1-nx;
          
          %calculate D1 and D2 based on gradient orientation
          D1 = nx * gradients(i+1,j+1) + ny * gradients(i,j+1);
          D2 = nx * gradients(i-1,j-1) + ny * gradients(i,j-1);
          
          %compare gradient with D1 and D2
          if ((gradients(i,j) > D1) && (gradients(i,j) > D2))
              edges(i,j) = gradients(i,j);
          else
              edges(i,j) = 0;
          end
          
      % Part 2: Angles 45° - 90° (Actual angle: -45° - -90°)
      elseif ((orientations(i,j) > 45) && (orientations(i,j) <= 90))
          angle = 90 - orientations(i,j); % here we need the inside angle
          nx = 1 * tan(angle*pi/180); % length of the opposite in a unit circle
          ny = 1-nx;
          
          D1 = nx * gradients(i+1,j+1) + ny * gradients(i+1,j);
          D2 = nx * gradients(i-1,j-1) + ny * gradients(i-1,j);
          
          if ((gradients(i,j) > D1) && (gradients(i,j) > D2))
              edges(i,j) = gradients(i,j);
          else
              edges(i,j) = 0;
          end
          
      % Part 3: Angles 0° - -45° (Actual angle: 0° - 45°)
      elseif ((orientations(i,j) < 0) && (orientations(i,j) >= -45))
          angle = -orientations(i,j); % remove the minus
          nx = 1 * tan(angle*pi/180); % length of the opposite in a unit circle
          ny = 1-nx;
          
          D1 = nx * gradients(i-1,j+1) + ny * gradients(i,j+1);
          D2 = nx * gradients(i+1,j-1) + ny * gradients(i,j-1);
          
          if ((gradients(i,j) > D1) && (gradients(i,j) > D2))
              edges(i,j) = gradients(i,j);
          else
              edges(i,j) = 0;
          end
          
      % Part 4: Angles -45° - -90° (Actual angle: 45° - 90°)
      elseif ((orientations(i,j) < -45) && (orientations(i,j) >= -90))
          angle = 90 + orientations(i,j); % here we need the inside angle
          nx = 1 * tan(angle*pi/180); % length of the opposite in a unit circle
          ny = 1-nx;
          
          D1 = nx * gradients(i-1,j+1) + ny * gradients(i-1,j);
          D2 = nx * gradients(i+1,j-1) + ny * gradients(i+1,j);
          
          if ((gradients(i,j) > D1) && (gradients(i,j) > D2))
              edges(i,j) = gradients(i,j);
          else
              edges(i,j) = 0;
          end
          
      end
        
    end
    
end

 


end