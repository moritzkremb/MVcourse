%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  desc = patch_sort_circle(patch)
%  purpose : Compute sorted normalised pixel intensity descriptor in a
%            circular region of the patch
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     patch: Patch from a grayscale image (n x n)
%
%  output   arguments
%     desc: image patch intensities from the pixels inside a circle at the
%           centre of the patch concatenated into normalised, sorted
%           vector. Size will vary depending on patch size.
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function desc = patch_sort_circle(patch)

% circle_mask
patch_size = size(patch, 1);
c_mask = circle_mask(patch_size);

% extract
new_patch = c_mask .* patch;

% normalize and sort
desc = patch_sort(new_patch);

end