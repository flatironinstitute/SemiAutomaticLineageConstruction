
function [A] = RandomRotoationMatrix(seed)


q = randrot;
A = quat2rotm(q);

end
