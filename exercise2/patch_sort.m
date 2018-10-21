%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  desc = patch_sort(patch)
%  purpose : Compute sorted normalised pixel intensity descriptor
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     patch: Patch from a grayscale image (n x n)
%
%  output   arguments
%     desc: image patch intensities concatenated into normalised, sorted
%           vector (1 x n*n)
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function desc = patch_sort(patch)

A = patch_norm(patch); % normalised 1 x n*n
desc = sort(A); % sorted

end