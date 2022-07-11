
function [U] = RandomRotoationMatrix(seed)

% select random locations on the sphere
rng(seed);

% randomly rotate points
A = zeros(3,3);
for i=1:3
    for j=1:3
        A(i,j) = randn();
    end
end
[U,S,V] = svd(A);
end
 
