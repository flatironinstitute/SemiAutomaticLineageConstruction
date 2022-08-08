


function [A] = RandomRotoationMatrix(seed) 
% select random locations on the sphere
rng(seed);
A = zeros(3,3);
for i=1:3
    for j=1:3
        A(i,j) = randn();
     end
end
ortho_error = 100;
ntests = 0;
while  (ortho_error > 1e-9)
    At = transpose(A);
   % what happens if A not invertible? return Infs
    Ainv = inv(At);
    A = (A + Ainv)/2;
   % how orthogonal?
   test_ortho = A*transpose(A);
   % take mean square error between test_ortho and identity
    error_mat =test_ortho - eye(3,3);
    [sumsq, n] = sumsqr(error_mat);
    ortho_error = sumsq/n;
    ntests = ntests + 1;
    if (ntests > 12)
        A = zeros(3,3);
        for i=1:3
            for j=1:3
                A(i,j) = randn();
            end
        end
    end
    sav_ortho_error = ortho_error;
end
ntests
ortho_error

