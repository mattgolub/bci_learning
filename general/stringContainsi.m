function result = stringContainsi(str, pattern)
%
% @ Matt Golub, 2018.

if isa(str,'cell')
    result = false(size(str));
    for i = 1:numel(str)
        result(i) = ~isempty(strfind(lower(str{i}), lower(pattern)));
    end
else
    result = ~isempty(strfind(lower(str), lower(pattern)));
end