function p = percentChange(start,stop)

if isequal(size(start),size(stop))
    p = 100*(stop-start)./start;
elseif numel(start) == numel(stop)
    p = 100*(stop(:)-start(:))./start(:);
else
    error('Inputs must have matching size.');
end