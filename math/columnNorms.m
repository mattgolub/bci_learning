function y = columnNorms(x)
%
% @ Matt Golub, 2018.

y = sqrt(sum(x.^2,1));

end