function y = normalizeColumns(x)
y = bsxfun(@rdivide,x,columnNorms(x));
end