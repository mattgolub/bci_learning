function y = ceilToNearestN(x,N)
% Round down to the nearest multiple of N.
%
% @ Matt Golub, 2018.

y = ceil(x/N)*N;