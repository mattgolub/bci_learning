function y = floorToNearestN(x,N)
% Round down to the nearest multiple of N.
%
% @ Matt Golub, 2018.

y = floor(x/N)*N;