function K = findRowsOfAInB(A,B)
% K are indices into rows of B. If row i of A cannot be found in B,
% K(i) is NaN;
%
% @ Matt Golub, 2018.

N = size(A,1);
K = nan(N,1);
for n = 1:N
    idx = find(all(bsxfun(@eq,A(n,:),B),2),1,'first');
    if ~isempty(idx)
        K(n) = idx;
    end
end
end