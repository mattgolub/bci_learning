function y = normalizeColumns(x)%
% @ Matt Golub, 2018.

y = bsxfun(@rdivide,x,columnNorms(x));
end