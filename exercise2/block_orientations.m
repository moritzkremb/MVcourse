%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  desc = block_orientations(patch)
%  purpose : Compute orientation-histogram based descriptor from a patch,
%            using blocks to divide the patch into regions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     patch: Patch from a grayscale image (16 x 16)
%
%  output   arguments
%     desc: Orientation histograms from 16 4 x 4 blocks of the patch,
%           concatenated in row major order (1 x 128).
%           Each orientation histogram should consist of 8 bins in the
%           range [-pi, pi], each bin being weighted by the sum of gradient
%           magnitudes of pixel orientations assigned to that bin.
%
%           You can use kron(reshape(1:16, 4, 4)', ones(4)) as a test
%           patch to see if block ordering is correct.
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function desc = block_orientations(patch)

% gradient magnitude and orientation

h = [1 0 -1];
Px = imfilter(patch, h, 'conv', 'replicate');
Py = imfilter(patch, h', 'conv', 'replicate');

gradient_mags = sqrt(Px.^2 + Py.^2);
orientations = atan2(Py, Px);

% split patch into 4x4 blocks

N = 4 * ones(1, 4);
orientation_blocks = mat2cell(orientations, N, N);
gradient_blocks = mat2cell(gradient_mags, N, N);

% concatenate into a matrix with blocks in one column

orientation_blocks = orientation_blocks'; 
orientation_blocks = orientation_blocks(:); % blocks in row major order

gradient_blocks = gradient_blocks';
gradient_blocks = gradient_blocks(:);

% now we make matrices with one block in every row

orientation_vectors = zeros(16, 16); % initialize
gradient_vectors = zeros(16, 16);

for i = 1:16
    o_cell = orientation_blocks{i};
    orientation_vectors(i, :) = o_cell(:); % unroll the block into a row
    
    g_cell = gradient_blocks{i};
    gradient_vectors(i, :) = g_cell(:);
end

% Create weighted histogram

edges = -pi : pi/4 : pi;
hist_weight = zeros(16, 8);

for k = 1:16
    o_block = orientation_vectors(k, :);
    discretized = discretize(o_block, edges); % this shows into which histogram it was sorted
    
    g_block = gradient_vectors(k, :); % we need this to calculate the weights

    for l = 1:16
        bin = discretized(l); % the bin it was sorted in
        hist_weight(k, bin) = hist_weight(k, bin) + g_block(l); % weight
    end
end

% normalize blocks individually and concatenate

hist_weight_norm = hist_weight ./ max(hist_weight,[], 2);
desc = reshape(hist_weight_norm.', 1, []);

end

