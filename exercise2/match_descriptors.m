%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  function  matchesAB = match_descriptors(descriptorsA, descriptorsB)
%  purpose :    Find matches for descriptors
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  input   arguments
%     descriptorsA:   patch descriptors of first image. m x n matrix
%                     containing m descriptors of length n
%     descriptorsB:   patch descriptors of second image. m x n matrix
%                     containing m descriptors of length n
%
%  output   arguments
%     matchesAB:      k x 2 matrix representing the k successful matches.
%                     Each row vector contains the indices of the matched
%                     descriptors of the first and the second image
%                     respectively.
%
%   Author: Moritz Kremb
%   MatrNr: 11722601
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function matchesAB = match_descriptors(descriptorsA, descriptorsB)

% Calculate "distances" (Intensity differences) for every Xb to every Xa

size_A = size(descriptorsA, 1);
size_B = size(descriptorsB, 1);
distances = zeros(size_A, size_B); % init

for i = 1:size_A    
    Xa = descriptorsA(i, :); % Xa

    for j = 1:size_B   
        Xb = descriptorsB(j, :); % Xb
        distances(i, j) = sum(abs(Xa - Xb)); % substract and then sum up
    end
end

% Sort the distances matrix by row

sorted_distances = sort(distances, 2);

% Compare and select the best match, then create matchesAB

matches = zeros(size_A, 1); % init
matchesAB = zeros(size_A, 2); % init

for k = 1:size_A
    for l = 1:size_B-1
        d1 = sorted_distances(k, l); % distance 1
        d2 = sorted_distances(k, l+1); % compare with next distance in row
                
        if (d1/d2 < 0.8)
            matches(k) = d1; % only add to matches if critera fulfilled
            break;
        elseif (l == size_B-1)
            matches(k) = NaN; % if reached the end set to NaN, no match found
        end
    end
    
    % Now that we have found the shortest distance, we find the indice of
    % the descriptor it belonged to
    distance_vector = distances(k, :); % original vector with distances in correct order
    dB_indice = find (distance_vector == d1); % find position in that vector
    
    matchesAB(k, 1) = k; % descriptor A indice
    matchesAB(k, 2) = dB_indice; % descriptor B indice 
end
            
end